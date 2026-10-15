package com.ptit.devops.lab.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "labs")
public class Lab {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "lab_name")
    private String labName;

    @Column(name = "building")
    private String building;

    @Column(name = "capacity")
    private Integer capacity;

    @Column(name = "equipment")
    private String equipment;

    @Column(name = "status")
    private String status;

    public Long getId() {
        return id;
    }

    public String getLabName() {
        return labName;
    }

    public String getBuilding() {
        return building;
    }

    public Integer getCapacity() {
        return capacity;
    }

    public String getEquipment() {
        return equipment;
    }

    public String getStatus() {
        return status;
    }
}
