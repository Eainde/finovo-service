package com.finovo.entity;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.PersistenceCreator;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("appl_user")
@Getter
@Setter
@NoArgsConstructor(onConstructor_ = @__(@PersistenceCreator))
public class UserEntity {
  @Id private long id;
  private String username;
  private String email;
  private String password;
  private int age;
  private String role;
  private double salary;
  private String goal;

  UserEntity(long id,String username,String email,String password,int age,String role,double salary,String goal){
    this.id = id;
    this.username = username;
    this.email = email;
    this.password = password;
    this.age = age;
    this.role = role;
    this.salary = salary;
    this.goal = goal;
  }
}
