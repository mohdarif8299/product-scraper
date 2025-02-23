import { useState } from "react"

const ProductCard = ({ product }) => {
    const [isDescriptionExpanded, setIsDescriptionExpanded] = useState(false)

    const toggleDescription = () => {
        setIsDescriptionExpanded(!isDescriptionExpanded)
    }

    return (
        <div className="product-card">
            <div className="product-image-container">
                <img src={product.image || "/placeholder.svg"} alt={product.title} className="product-image" />
            </div>
            <div className="product-details">
                <h2 className="product-title">{product.title}</h2>
                <p className="product-category">{product.category.name}</p>
                <p className="product-price">Rs. {product.price}</p>
                <p className="product-description">
                    {isDescriptionExpanded ? product.description : `${product.description.slice(0, 100)}...`}
                    {product.description.length > 100 && (
                        <button onClick={toggleDescription} className="read-more-button">
                            {isDescriptionExpanded ? "Read Less" : "Read More"}
                        </button>
                    )}
                </p>
                <a href={product.url} target="_blank" rel="noopener noreferrer" className="view-original-link">
                    View Original
                </a>
            </div>
        </div>
    )
}

export default ProductCard