import 'package:flutter/material.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/data/models/product_model.dart';

/// بطاقة المنتج مع دعم RTL والتصميم العربي
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final bool isInCart;
  final bool isFavorite;
  final bool showActions;
  final double? width;
  final double? height;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.isInCart = false,
    this.isFavorite = false,
    this.showActions = true,
    this.width,
    this.height,
  });

  /// بطاقة منتج مضغوطة للقائمة الأفقية
  factory ProductCard.compact({
    Key? key,
    required ProductModel product,
    VoidCallback? onTap,
    VoidCallback? onAddToCart,
    VoidCallback? onFavorite,
    bool isInCart = false,
    bool isFavorite = false,
  }) {
    return ProductCard(
      key: key,
      product: product,
      onTap: onTap,
      onAddToCart: onAddToCart,
      onFavorite: onFavorite,
      isInCart: isInCart,
      isFavorite: isFavorite,
      width: 160,
      height: 220,
      showActions: true,
    );
  }

  /// بطاقة منتج للعرض في الشبكة
  factory ProductCard.grid({
    Key? key,
    required ProductModel product,
    VoidCallback? onTap,
    VoidCallback? onAddToCart,
    VoidCallback? onFavorite,
    bool isInCart = false,
    bool isFavorite = false,
  }) {
    return ProductCard(
      key: key,
      product: product,
      onTap: onTap,
      onAddToCart: onAddToCart,
      onFavorite: onFavorite,
      isInCart: isInCart,
      isFavorite: isFavorite,
      showActions: true,
    );
  }

  /// بطاقة منتج للعرض في القائمة العمودية
  factory ProductCard.list({
    Key? key,
    required ProductModel product,
    VoidCallback? onTap,
    VoidCallback? onAddToCart,
    VoidCallback? onFavorite,
    bool isInCart = false,
    bool isFavorite = false,
  }) {
    return ProductCard(
      key: key,
      product: product,
      onTap: onTap,
      onAddToCart: onAddToCart,
      onFavorite: onFavorite,
      isInCart: isInCart,
      isFavorite: isFavorite,
      height: 120,
      showActions: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: height != null && height! < 200 ? 2 : 3,
                child: _buildProductImage(),
              ),
              Expanded(flex: 2, child: _buildProductInfo()),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء صورة المنتج
  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: AppColors.backgroundColor,
      ),
      child: Stack(
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),

          // شارات المنتج
          Positioned(top: 8, right: 8, child: _buildProductBadges()),

          // أزرار الإجراءات
          if (showActions)
            Positioned(top: 8, left: 8, child: _buildActionButtons()),
        ],
      ),
    );
  }

  /// بناء صورة مؤقتة
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.backgroundColor,
      child: Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// بناء مؤشر تحميل الصورة
  Widget _buildLoadingImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.backgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      ),
    );
  }

  /// بناء شارات المنتج
  Widget _buildProductBadges() {
    return Column(
      children: [
        // شارة المنتج المميز
        if (product.isFeatured)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warningColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'مميز',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),

        // شارة عدم التوفر
        if (!product.isAvailable) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'غير متوفر',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],

        // شارة المخزون المنخفض
        if (product.stockQuantity != null &&
            product.stockQuantity! < 5 &&
            product.stockQuantity! > 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.errorColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'كمية قليلة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// بناء أزرار الإجراءات
  Widget _buildActionButtons() {
    return Column(
      children: [
        // زر المفضلة
        if (onFavorite != null)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isFavorite
                    ? AppColors.errorColor
                    : AppColors.textSecondary,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }

  /// بناء معلومات المنتج
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم المنتج
          Expanded(
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          // التقييم
          if (product.rating != null && product.rating! > 0) ...[
            Row(
              children: [
                Icon(Icons.star, size: 12, color: AppColors.ratingStarColor),
                const SizedBox(width: 2),
                Text(
                  product.rating!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],

          // السعر
          Row(
            children: [
              // السعر الحالي
              Text(
                '${product.price.toStringAsFixed(0)} د.ع',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.priceColor,
                  fontFamily: 'Cairo',
                ),
              ),

              const Spacer(),

              // زر إضافة إلى السلة
              if (showActions && onAddToCart != null && product.isAvailable)
                GestureDetector(
                  onTap: onAddToCart,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isInCart
                          ? AppColors.successColor
                          : AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isInCart ? Icons.check : Icons.add,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// بطاقة منتج أفقية
class HorizontalProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isInCart;
  final double height;

  const HorizontalProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isInCart = false,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // صورة المنتج
              Container(
                width: height,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  color: AppColors.backgroundColor,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.inventory_2_outlined,
                              size: 32,
                              color: AppColors.textSecondary,
                            );
                          },
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          size: 32,
                          color: AppColors.textSecondary,
                        ),
                ),
              ),

              // معلومات المنتج
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // اسم المنتج
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // السعر والإجراءات
                      Row(
                        children: [
                          // السعر
                          Text(
                            '${product.price.toStringAsFixed(0)} د.ع',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.priceColor,
                              fontFamily: 'Cairo',
                            ),
                          ),

                          const Spacer(),

                          // زر إضافة إلى السلة
                          if (onAddToCart != null && product.isAvailable)
                            GestureDetector(
                              onTap: onAddToCart,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isInCart
                                      ? AppColors.successColor
                                      : AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  isInCart ? Icons.check : Icons.add,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
