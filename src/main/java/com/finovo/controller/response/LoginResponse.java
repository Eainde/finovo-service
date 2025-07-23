package com.finovo.controller.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class LoginResponse {
    private long id;
    private String username;
    private String email;
    private String password;
    private int age;
    private String role;
    private double salary;
    private String goal;
}
