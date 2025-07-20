package com.finovo.controller.response;

import lombok.Builder;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Builder
@Getter
@Setter
public class LoginResponse {
    private String username;
    private String email;
}
