import { useState, useEffect } from "react"
import { debounce } from "lodash"
import ProductCard from "./ProductCard"

const ProductList = () => {
    const [products, setProducts] = useState([])
    const [search, setSearch] = useState("")
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState(null)
    const [url, setUrl] = useState("")
    const [selectedCategory, setSelectedCategory] = useState("")
    const [categories, setCategories] = useState([])
    const [filteredProducts, setFilteredProducts] = useState([])

    const fetchProducts = async () => {
        setLoading(true)
        setError(null)
        try {
            const response = await fetch("/api/v1/products")
            if (!response.ok) {
                throw new Error("Failed to fetch products")
            }
            const data = await response.json()
            setProducts(Array.isArray(data) ? data : Array.isArray(data.products) ? data.products : [])
            setFilteredProducts(data)
        } catch (error) {
            console.error("Error fetching products:", error)
            setError("Failed to load products. Please try again later.")
            setProducts([])
            setFilteredProducts([])
        }
        setLoading(false)
    }

    const fetchCategories = async () => {
        try {
            const response = await fetch("/api/v1/categories")
            if (!response.ok) {
                throw new Error("Failed to fetch categories")
            }
            const data = await response.json()
            setCategories(data)
        } catch (error) {
            console.error("Error fetching categories:", error)
            setError("Failed to load categories. Please try again later.")
        }
    }

    const debouncedSearch = debounce((term) => {
        filterProducts(term, selectedCategory)
    }, 300)

    const filterProducts = (searchTerm, category) => {
        let filtered = products

        if (searchTerm) {
            filtered = filtered.filter((product) => product.title.toLowerCase().includes(searchTerm.toLowerCase()))
        }

        if (category) {
            filtered = filtered.filter((product) => product.category.name === category)
        }

        setFilteredProducts(filtered)
    }

    useEffect(() => {
        fetchProducts()
        fetchCategories()
    }, [])

    const handleSearchChange = (e) => {
        setSearch(e.target.value)
        debouncedSearch(e.target.value)
    }

    const handleCategoryChange = (e) => {
        setSelectedCategory(e.target.value)
        filterProducts(search, e.target.value)
    }

    const handleSubmitUrl = async (e) => {
        e.preventDefault()
        setLoading(true)
        setError(null)
        try {
            const response = await fetch("/api/v1/products", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({ product: { url } }),
            })
            if (!response.ok) {
                throw new Error("Failed to scrape product")
            }
            setUrl("")
            await fetchProducts()
        } catch (error) {
            console.error("Error submitting URL:", error)
            setError("Failed to scrape product. Please check the URL and try again.")
        }
        setLoading(false)
    }

    return (
        <div className="product-list-container">
            <h1 className="product-list-title">Product Scraper</h1>

            <form onSubmit={handleSubmitUrl} className="url-form">
                <input
                    type="url"
                    value={url}
                    onChange={(e) => setUrl(e.target.value)}
                    placeholder="Enter product URL"
                    className="url-input"
                    required
                />
                <button type="submit" disabled={loading} className="submit-button">
                    {loading ? "Loading..." : "Scrape"}
                </button>
            </form>

            <div className="filter-row">
                <div className="search-container">
                    <input
                        type="text"
                        value={search}
                        onChange={handleSearchChange}
                        placeholder="Search products..."
                        className="search-input"
                    />
                </div>
                <div className="category-container">
                    <select value={selectedCategory} onChange={handleCategoryChange} className="category-select">
                        <option value="">All Categories</option>
                        {categories.map((category) => (
                            <option key={category.id} value={category.name}>
                                {category.name}
                            </option>
                        ))}
                    </select>
                </div>
            </div>

            {error && <div className="error-message">{error}</div>}

            {loading ? (
                <p> Loading Products...</p>
            ) : filteredProducts.length > 0 ? (
                <div className="product-grid">
                    {filteredProducts.map((product) => (
                        <ProductCard key={product.id} product={product} />
                    ))}
                </div>
            ) : (
                <div className="no-results">No products found. Try adjusting your search or filters.</div>
            )}
        </div>
    )
}

export default ProductList