package csd230.bookstore;


import com.github.javafaker.Commerce;
import com.github.javafaker.Faker;
import csd230.bookstore.entities.BookEntity;
import csd230.bookstore.entities.CartEntity;
import csd230.bookstore.entities.UserEntity;
import csd230.bookstore.repositories.CartEntityRepository;
import csd230.bookstore.repositories.ProductEntityRepository;
import csd230.bookstore.repositories.UserEntityRepository;
import csd230.bookstore.entities.DvdEntity;
import csd230.bookstore.repositories.DvdEntityRepository;
import jakarta.transaction.Transactional;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;


@SpringBootApplication
public class Application implements CommandLineRunner {
    private final ProductEntityRepository productRepository;
    private final CartEntityRepository cartRepository;
    private final UserEntityRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final DvdEntityRepository dvdRepository;


    public Application(ProductEntityRepository productRepository,
                       CartEntityRepository cartRepository,
                       UserEntityRepository userRepository,
                       DvdEntityRepository dvdRepository,
                       PasswordEncoder passwordEncoder
    ) {
        this.productRepository = productRepository;
        this.cartRepository = cartRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.dvdRepository = dvdRepository;
    }


    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }


    @Override
    @Transactional
    public void run(String... args) throws Exception {
        Faker faker = new Faker();
        Commerce cm = faker.commerce();
        com.github.javafaker.Number number = faker.number();
        com.github.javafaker.Book fakeBook = faker.book();
        String name = cm.productName();
        String description = cm.material();

        for (int i = 0; i < 10; i++) {
            // We call the faker methods inside the loop so each book gets unique data
            String title = faker.book().title();
            String author = faker.book().author();
            String priceString = faker.commerce().price();

            // Create the book entity with the random data
            BookEntity book = new BookEntity(
                    title,
                    Double.parseDouble(priceString),
                    10,      // Defaulting to 10 copies each
                    author
            );

            // Save to database
            productRepository.save(book);

            System.out.println("Saved Book " + (i + 1) + ": " + title + " by " + author);
        }



        // ------------------------------------
        // CREATE USERS (Lecture 2.6)
        // ------------------------------------


        // Admin User (Can Add/Edit/Delete)
        UserEntity admin = new UserEntity("admin", passwordEncoder.encode("admin"), "ADMIN");
        userRepository.save(admin);


        // Regular User (Can only View/Buy)
        UserEntity user = new UserEntity("user", passwordEncoder.encode("user"), "USER");
        userRepository.save(user);


        System.out.println("Default users created: admin/admin and user/user");

        // Check if a cart exists, if not, create one
        if (cartRepository.count() == 0) {
            CartEntity defaultCart = new CartEntity();
            cartRepository.save(defaultCart);
            System.out.println("Default Cart created with ID: " + defaultCart.getId());
        }
        // DVD Seed Data
        if (dvdRepository.count() == 0) {
            dvdRepository.save(new DvdEntity("Inception",         12.99, 25, "Christopher Nolan", "Sci-Fi",    2010, "PG-13"));
            dvdRepository.save(new DvdEntity("The Matrix",        11.99, 30, "The Wachowskis",    "Action",    1999, "R"));
            dvdRepository.save(new DvdEntity("Interstellar",      14.99, 20, "Christopher Nolan", "Sci-Fi",    2014, "PG-13"));
            dvdRepository.save(new DvdEntity("Parasite",          13.99, 18, "Bong Joon-ho",      "Thriller",  2019, "R"));
            dvdRepository.save(new DvdEntity("Coco",              12.99, 35, "Lee Unkrich",       "Animation", 2017, "PG"));
            dvdRepository.save(new DvdEntity("Arrival",           11.99, 20, "Denis Villeneuve",  "Sci-Fi",    2016, "PG-13"));
            dvdRepository.save(new DvdEntity("Knives Out",        13.99, 28, "Rian Johnson",      "Mystery",   2019, "PG-13"));
            dvdRepository.save(new DvdEntity("Dune",              15.99, 40, "Denis Villeneuve",  "Sci-Fi",    2021, "PG-13"));
            dvdRepository.save(new DvdEntity("Mad Max Fury Road", 12.99, 15, "George Miller",     "Action",    2015, "R"));
            dvdRepository.save(new DvdEntity("Clueless",           9.99, 22, "Amy Heckerling",    "Comedy",    1995, "PG-13"));
            System.out.println("DVD seed data loaded.");
        }
    }


    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                // Allow access to all /api endpoints from any origin
                registry.addMapping("/api/**").allowedOrigins("*");
            }
        };
    }



}

