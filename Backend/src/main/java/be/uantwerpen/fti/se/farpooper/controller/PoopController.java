package be.uantwerpen.fti.se.farpooper.controller;

import be.uantwerpen.fti.se.farpooper.model.Poop;
import be.uantwerpen.fti.se.farpooper.model.dto.PoopDto;
import be.uantwerpen.fti.se.farpooper.service.PoopService;
import be.uantwerpen.fti.se.farpooper.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/Poops")

public class PoopController {

    private final PoopService poopService;
    private final UserService userService;

    public PoopController(PoopService poopService, UserService userService) {
        this.poopService = poopService;
        this.userService = userService;
    }

    @GetMapping("/all")
    public Iterable<Poop> getAllPoops() {
        return  poopService.GetAllPoops();
    }

    @GetMapping("/uid/{uid}")
    public Iterable<Poop> getUserPoops(@PathVariable("uid") String uid) {
        return poopService.getUserPoops(uid);
    }

    @PutMapping("/add")
    public ResponseEntity<?> NewPoop(@Valid @RequestBody PoopDto poopDto) {
        if(userService.UserExists(poopDto.getUid())) {
            int Points = poopService.addPoop(poopDto);
            if (Points > 0) {
                return ResponseEntity.status(HttpStatus.OK).body(Points);
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Poop was not added");
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("The User does not exist");
    }

}
