package com.ptit.devops.lab.controller;

import com.ptit.devops.lab.entity.Lab;
import com.ptit.devops.lab.repository.LabRepository;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class LabController {

    private final LabRepository repository;

    public LabController(LabRepository repository) {
        this.repository = repository;
    }

    /** GET /api/labs - danh sách phòng lab */
    @GetMapping("/labs")
    public List<Lab> findAll() {
        return repository.findAll(Sort.by("id"));
    }
}
