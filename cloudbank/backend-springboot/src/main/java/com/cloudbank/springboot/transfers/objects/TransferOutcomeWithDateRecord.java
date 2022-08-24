package com.cloudbank.springboot.transfers.objects;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.util.Date;

public class TransferOutcomeWithDateRecord extends TransferOutcome {

    @JsonFormat(pattern="yyyy-MM-dd HH:mm:ss")
    private  Date transactionDate;

    public TransferOutcomeWithDateRecord(String outcome, Date transactionDate) {
        super(outcome);
        this.transactionDate=transactionDate;
    }

    public Date getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(Date transaction) {
        this.transactionDate = transaction;
    }
}
