package com.project.model;

import java.io.Serializable;

public class LeaveRequest implements Serializable {
    private static final long serialVersionUID = 1L;

    private int leaveId;
    private String studentUsn;
    private String studentName; // Utility field for admin display
    private String fromDate;
    private String toDate;
    private String reason;
    private String status;

    public LeaveRequest() {}

    public int getLeaveId() { return leaveId; }
    public void setLeaveId(int leaveId) { this.leaveId = leaveId; }

    public String getStudentUsn() { return studentUsn; }
    public void setStudentUsn(String studentUsn) { this.studentUsn = studentUsn; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getFromDate() { return fromDate; }
    public void setFromDate(String fromDate) { this.fromDate = fromDate; }

    public String getToDate() { return toDate; }
    public void setToDate(String toDate) { this.toDate = toDate; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
