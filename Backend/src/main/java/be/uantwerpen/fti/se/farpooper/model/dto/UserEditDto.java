package be.uantwerpen.fti.se.farpooper.model.dto;

import be.uantwerpen.fti.se.farpooper.model.Pair;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UserEditDto {
    @NotBlank(message = "Username is required")
    String username;

    @NotBlank(message = "uid is required")
    String uid;

    @NotBlank(message = "HomeCoords are required is required")
    Pair<Float, Float> homeCords;

    @NotBlank(message = "Email is mandatory")
    @Email(message = "Email should be valid")
    String email;
}
