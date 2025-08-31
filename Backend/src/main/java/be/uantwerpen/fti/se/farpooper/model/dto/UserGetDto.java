package be.uantwerpen.fti.se.farpooper.model.dto;

import be.uantwerpen.fti.se.farpooper.model.Pair;
import be.uantwerpen.fti.se.farpooper.model.Poop;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserGetDto {
    private String jwtToken;
    private long id;
    private String username;
    private String email;
    private Set<Poop> poops;
    private Pair<Float, Float> HomeCords;
}
