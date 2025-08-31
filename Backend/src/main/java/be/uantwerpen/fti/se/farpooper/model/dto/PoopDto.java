package be.uantwerpen.fti.se.farpooper.model.dto;

import be.uantwerpen.fti.se.farpooper.model.Pair;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class PoopDto {

    @NotBlank(message = "User Id is required")
    private String uid;
    @NotBlank(message = "skinId is required")
    private Long skinId;
    @NotBlank(message = "Name is required")
    private String name;
    @NotBlank(message = "coordinates is required")
    private Pair<Float, Float> coordinates;
}
