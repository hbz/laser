package com.k_int.kbplus.batch

import de.laser.quartz.AbstractJob

class IndexUpdateJob extends AbstractJob {

    def dataloadService

    static triggers = {
        // Delay 120 seconds, run every 10 mins.
        cron name:'cronTrigger', startDelay:190000, cronExpression: "0 0/10 7-20 * * ?"
    }

    static configFlags = []

    boolean isAvailable() {
        !jobIsRunning
    }
    boolean isRunning() {
        jobIsRunning
    }

    def execute() {
        if (! isAvailable()) {
            return false
        }
        jobIsRunning = true

        log.debug("****Running Index Update Job****")

        dataloadService.doFTUpdate()

        jobIsRunning = false
    }
}
