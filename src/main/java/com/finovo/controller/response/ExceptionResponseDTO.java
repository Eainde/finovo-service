package com.finovo.controller.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@Builder
public class ExceptionResponseDTO {
    private int code;
    private String error;
}
