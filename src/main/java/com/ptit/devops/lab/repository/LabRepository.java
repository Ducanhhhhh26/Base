package com.ptit.devops.lab.repository;

import com.ptit.devops.lab.entity.Lab;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LabRepository extends JpaRepository<Lab, Long> {
}
