/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.csiro.flower.service;

import com.amazonaws.services.cloudwatch.model.Datapoint;
import com.amazonaws.services.cloudwatch.model.GetMetricStatisticsResult;
import com.csiro.flower.dao.CtrlStatsDao;
import com.csiro.flower.dao.KinesisCtrlDao;
import com.csiro.flower.model.CloudSetting;
import com.csiro.flower.model.KinesisCtrl;
import java.sql.Timestamp;
import java.util.Date;
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

/**
 *
 * @author kho01f
 */
//@Service
//@Scope("prototype")
public class KinesisCtrlServiceImpl extends CtrlService implements Runnable {

    @Autowired
    private KinesisMgmtService kinesisMgmtService;

    @Autowired
    private KinesisCtrlDao kinesisCtrlDao;

    @Autowired
    private CloudWatchService cloudWatchService;

    private ScheduledFuture<?> futureTask;

    public ScheduledFuture<?> getFutureTask() {
        return futureTask;
    }

    public void setFutureTask(ScheduledFuture<?> futureTask) {
        this.futureTask = futureTask;
    }

    Queue kinesisCtrlGainQ;
    private final String ctrlName = "AmazonKinesis";
    private int ctrlId;
    private String streamName;
    private String measurementTarget;
    private double putRecordUtilizationRef;
    private int backoffNo;

    public void setupController(CloudSetting cloudSetting, KinesisCtrl kinesisCtrl) {

        initValues(kinesisCtrl);

        initService(
                cloudSetting.getCloudProvider(),
                cloudSetting.getAccessKey(),
                cloudSetting.getSecretKey(),
                cloudSetting.getRegion());

        ctrlStatsDao.saveCtrlStatus(ctrlId, ctrlName, RUNNING_STATUS, new Timestamp(new Date().getTime()));
    }

    private void initValues(KinesisCtrl kinesisCtrl) {
        kinesisCtrlGainQ = new LinkedList<>();
        streamName = kinesisCtrl.getStreamName();
        measurementTarget = kinesisCtrl.getMeasurementTarget();
        putRecordUtilizationRef = kinesisCtrl.getRefValue();
        backoffNo = kinesisCtrl.getBackoffNo();
        ctrlId = kinesisCtrlDao.getPkId(kinesisCtrl.getFlowIdFk(), kinesisCtrl.getStreamName());
    }

    private void initService(String provider, String accessKey, String secretKey, String region) {
        cloudWatchService.initService(provider, accessKey, secretKey, region);
        kinesisMgmtService.initService(provider, accessKey, secretKey, region);
    }

    @Override
    public void run() {
        if (!isCtrlStopped(ctrlId, ctrlName)) {
            runController();
        } else {
            futureTask.cancel(false);
        }
    }

    private boolean isCtrlStopped(int id, String ctrl) {
        return ctrlStatsDao.getCtrlStatus(id, ctrl).equals(STOPPED_STATUS);
    }

    private void runController() {
        double error;
        double k0;
        double uk0;
        double uk1;
        double putRecordUtilizationPercent;
        int roundedUk1;
        int roundedUk0;
        boolean isGainUpdated = false;

        double incomingRecords = getKinesisIncomingRecStat(streamName, measurementTarget);
        uk0 = kinesisMgmtService.getOpenShards(streamName).size();
        roundedUk0 = (int) Math.round(uk0);

        // One shard can support up to 1000 PUT records per second.
        putRecordUtilizationPercent = (incomingRecords / (uk0 * 1000)) * 100;

        if (kinesisCtrlGainQ.isEmpty()) {
            k0 = k_init;
        } else {
            k0 = (double) kinesisCtrlGainQ.poll();
            if (k0 >= upperK0) {
                k0 = upInitK0;
            }
            if (k0 <= lowerK0) {
                k0 = lowInitK0;
            }
        }
        error = (putRecordUtilizationPercent - putRecordUtilizationRef);
        uk1 = uk0 + k0 * error;
        roundedUk1 = (int) Math.round(Math.abs(uk1));

        ctrlStatsDao.saveCtrlMonitoringStats(ctrlId, ctrlName, error,
                new Timestamp(new Date().getTime()), k0, incomingRecords, uk0, uk1, roundedUk1);

        // If clouadwatch datapoint is null for current period, do not update gains and shard size!
        if (incomingRecords != 0) {
            if (uk1 > uk0) {
                roundedUk1 = roundedUk1 - roundedUk0;
                if (roundedUk1 != 0) {
                    kinesisMgmtService.increaseShards(streamName, roundedUk1);
                }
            } else if ((uk1 < uk0) && (uk0 != 1) /*&& (Math.abs(error) >= threshold)*/) {
                if (roundedUk1 <= 0) {
                    roundedUk1 = roundedUk0 - 1;
                } else {
                    roundedUk1 = roundedUk0 - roundedUk1;
                }
                kinesisMgmtService.decreaseShards(streamName, roundedUk1);
            }
//             If Ctrl descision revoked, do not update the gain
//            if ((uk1 < uk0) && ((uk0 == 1) /*|| (Math.abs(error) < threshold)*/)) {
//                kinesisCtrlGainQ.add(Math.abs(k0));
//            } else {
            kinesisCtrlGainQ.add(k0 + gamma * error);
            isGainUpdated = true;
//            }
//            kinesisCtrlGainQ.add(Math.abs(k0 + (lambda * ((incomingRecords / putRecordUtilizationRef) * 100))));
        }
        //Re-pass old gain if it has not updated!
        if (!isGainUpdated) {
            kinesisCtrlGainQ.add(Math.abs(k0));
        }
    }

    public double getKinesisIncomingRecStat(String streamName, String measurementTarget) {

        GetMetricStatisticsResult statsResult = cloudWatchService.
                getCriticalResourceStats(ctrlName, streamName, measurementTarget, twoMinMil);
        return getIncomingRecords(statsResult);
    }

    public double getIncomingRecords(GetMetricStatisticsResult result) {
        double val = 0;
        if (!result.getDatapoints().isEmpty()) {
            for (Datapoint dataPoint : result.getDatapoints()) {
                val += dataPoint.getSum();
            }
            return (val / twoMinSec);
        } else {
            return 0;
        }
    }

}
