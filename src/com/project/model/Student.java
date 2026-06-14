package com.project.model;

import java.io.Serializable;

public class Student implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String usn;
    private String name;
    private String email;
    private String password;

    public Student() {}

    public Student(String usn, String name, String email, String password) {
        this.usn = usn;
        this.name = name;
        this.email = email;
        this.password = password;
    }

    public String getUsn() { return usn; }
    public void setUsn(String usn) { this.usn = usn; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
