package csd230.bookstore.controllers;

import csd230.bookstore.entities.DvdEntity;
import csd230.bookstore.repositories.DvdEntityRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rest/dvds")
public class DvdController {

    private final DvdEntityRepository dvdRepository;

    public DvdController(DvdEntityRepository dvdRepository) {
        this.dvdRepository = dvdRepository;
    }

    @GetMapping
    public List<DvdEntity> getAllDvds() {
        return dvdRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<DvdEntity> getDvdById(@PathVariable Long id) {
        return dvdRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public DvdEntity createDvd(@RequestBody DvdEntity dvd) {
        return dvdRepository.save(dvd);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DvdEntity> updateDvd(@PathVariable Long id, @RequestBody DvdEntity updated) {
        return dvdRepository.findById(id).map(dvd -> {
            dvd.setTitle(updated.getTitle());
            dvd.setDirector(updated.getDirector());
            dvd.setGenre(updated.getGenre());
            dvd.setReleaseYear(updated.getReleaseYear());
            dvd.setRating(updated.getRating());
            dvd.setPrice(updated.getPrice());
            dvd.setCopies(updated.getCopies());
            return ResponseEntity.ok(dvdRepository.save(dvd));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDvd(@PathVariable Long id) {
        if (dvdRepository.existsById(id)) {
            dvdRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}