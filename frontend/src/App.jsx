import { useState, useEffect } from 'react';
import { Routes, Route } from 'react-router';
import Navbar from './NavBar';
import Home from './Home';
import Book from './Book';
import BookForm from './BookForm';
import Magazine from './Magazine';
import MagazineForm from './MagazineForm';
import Dvd from './Dvd';
import DvdForm from './DvdForm';
import Cart from './Cart';
import Login from './pages/Login';
import Logout from './pages/Logout';
import { ProtectedRoute } from './routes/ProtectedRoute';
import { useAuth } from './provider/authProvider';
import api from './api/axiosConfig';
import './App.css';

function App() {
    const { token } = useAuth();
    const [books, setBooks] = useState([]);
    const [magazines, setMagazines] = useState([]);
    const [dvds, setDvds] = useState([]);
    const [cartCount, setCartCount] = useState(0);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (!token) {
            setLoading(false);
            return;
        }
        const loadInitialData = async () => {
            try {
                const [booksRes, magsRes, dvdsRes, cartRes] = await Promise.all([
                    api.get('/books'),
                    api.get('/magazines'),
                    api.get('/dvds'),
                    api.get('/cart')
                ]);
                setBooks(booksRes.data);
                setMagazines(magsRes.data);
                setDvds(dvdsRes.data);
                setCartCount(cartRes.data.products.length);
            } catch (err) {
                console.error("Failed to load data", err);
            } finally {
                setLoading(false);
            }
        };
        loadInitialData();
    }, [token]);

    const handleAddToCart = async (productId) => {
        try {
            const res = await api.post(`/cart/add/${productId}`);
            setCartCount(res.data.products.length);
            alert("Added to cart!");
        } catch (err) {
            alert("Error adding to cart");
        }
    };

    // ── Books ──────────────────────────────────────────────
    const handleDeleteBook = async (id) => {
        if (!window.confirm("Delete book?")) return;
        await api.delete(`/books/${id}`);
        setBooks(books.filter(b => b.id !== id));
    };

    const handleUpdateBook = async (id, data) => {
        const res = await api.put(`/books/${id}`, data);
        setBooks(books.map(b => b.id === id ? res.data : b));
    };

    // ── Magazines ──────────────────────────────────────────
    const handleDeleteMagazine = (id) =>
        api.delete(`/magazines/${id}`).then(() =>
            setMagazines(magazines.filter(m => m.id !== id)));

    const handleUpdateMagazine = (id, data) =>
        api.put(`/magazines/${id}`, data).then(res =>
            setMagazines(magazines.map(m => m.id === id ? res.data : m)));

    // ── DVDs ───────────────────────────────────────────────
    const handleDeleteDvd = async (id) => {
        if (!window.confirm("Delete DVD?")) return;
        await api.delete(`/dvds/${id}`);
        setDvds(dvds.filter(d => d.id !== id));
    };

    const handleUpdateDvd = async (id, data) => {
        const res = await api.put(`/dvds/${id}`, data);
        setDvds(dvds.map(d => d.id === id ? res.data : d));
    };

    if (loading) return <h2>Loading Bookstore...</h2>;

    return (
        <div className="app-container">
            {token && <Navbar cartCount={cartCount} />}

            <Routes>
                {/* PUBLIC */}
                <Route path="/login" element={<Login />} />

                {/* PROTECTED */}
                <Route element={<ProtectedRoute />}>
                    <Route path="/" element={<Home />} />

                    {/* Books */}
                    <Route path="/inventory" element={
                        <div className="book-list">
                            <h1>Books</h1>
                            {books.map(b => (
                                <Book key={b.id} {...b}
                                      onDelete={handleDeleteBook}
                                      onUpdate={handleUpdateBook}
                                      onAddToCart={handleAddToCart} />
                            ))}
                        </div>
                    } />

                    {/* Magazines */}
                    <Route path="/magazines" element={
                        <div className="magazine-list">
                            <h1>Magazines</h1>
                            {magazines.map(m => (
                                <Magazine key={m.id} {...m}
                                          onAddToCart={handleAddToCart}
                                          onDelete={handleDeleteMagazine}
                                          onUpdate={handleUpdateMagazine} />
                            ))}
                        </div>
                    } />

                    {/* DVDs */}
                    <Route path="/dvds" element={
                        <div className="book-list">
                            <h1>DVDs</h1>
                            {dvds.map(d => (
                                <Dvd key={d.id} {...d}
                                     onDelete={handleDeleteDvd}
                                     onUpdate={handleUpdateDvd}
                                     onAddToCart={handleAddToCart} />
                            ))}
                        </div>
                    } />

                    {/* Cart */}
                    <Route path="/cart" element={
                        <Cart api={api} onCartChange={(count) => setCartCount(count)} />
                    } />

                    {/* Add Forms — Admin only */}
                    <Route path="/add" element={
                        <BookForm onBookAdded={(b) => setBooks([...books, b])} api={api} />
                    } />
                    <Route path="/add-magazine" element={
                        <MagazineForm onMagazineAdded={(m) => setMagazines([...magazines, m])} api={api} />
                    } />
                    <Route path="/add-dvd" element={
                        <DvdForm onDvdAdded={(d) => setDvds([...dvds, d])} api={api} />
                    } />

                    <Route path="/logout" element={<Logout />} />
                </Route>
            </Routes>
        </div>
    );
}

export default App;