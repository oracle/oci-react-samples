package com.cloudbank.springboot.transfers.objects;

/**
 * Rest response representation of transfer status/outcome
 */
public class TransferOutcome {
    public TransferOutcome(String outcome) {
        this.outcome = outcome;
    }

    public String getOutcome() {
        return outcome;
    }

    public void setOutcome(String outcome) {
        this.outcome = outcome;
    }

    private  String outcome;
}
