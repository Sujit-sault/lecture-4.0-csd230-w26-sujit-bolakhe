package csd230.bookstore.entities;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

import java.util.Objects;

@Entity @DiscriminatorValue("DVD")
public class DvdEntity extends PublicationEntity {
    private String director;
    private String genre;
    private int releaseYear;
    private String rating;

    public DvdEntity() {}

    public DvdEntity(String title, Double price, Integer copies, String director, String genre, int releaseYear, String rating) {
        super(title, price, copies);
        this.director = director;
        this.genre = genre;
        this.releaseYear = releaseYear;
        this.rating = rating;
    }

    public String getDirector() { return director; }
    public void setDirector(String director) { this.director = director; }

    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }

    public int getReleaseYear() { return releaseYear; }
    public void setReleaseYear(int releaseYear) { this.releaseYear = releaseYear; }

    public String getRating() { return rating; }
    public void setRating(String rating) { this.rating = rating; }

    @Override
    public String toString() {
        return "DvdEntity{" +
                "director='" + director + '\'' +
                ", genre='" + genre + '\'' +
                ", releaseYear=" + releaseYear +
                ", rating='" + rating + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        DvdEntity that = (DvdEntity) o;
        return releaseYear == that.releaseYear &&
                Objects.equals(director, that.director) &&
                Objects.equals(genre, that.genre) &&
                Objects.equals(rating, that.rating);
    }

    @Override
    public int hashCode() {
        return Objects.hash(director, genre, releaseYear, rating);
    }
}