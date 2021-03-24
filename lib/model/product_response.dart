class ProductResponse {
  int success;
  int status;
  String msg;
  List<Products> products;

  ProductResponse({this.success, this.status, this.msg, this.products});

  ProductResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    status = json['status'];
    msg = json['msg'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.products != null) {
      data['products'] = this.products.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String id;
  String sku;
  String categoryId;
  String name;
  String description;
  String image;
  String stock;
  String cogs;
  String price;
  String specialPrice;
  String isWholesale;
  String isVariant;
  String rating;
  String sold;
  String weight;
  String length;
  String width;
  String height;
  String weightMetricId;
  String volumeMetricId;
  String slug;
  String warrantyId;
  String point;
  String redeemable;
  String createdAt;
  String updatedAt;
  String productId;
  String cName;
  String category;
  String wName;
  String mwName;
  String mvName;
  List<VariantGroups> variantGroups;
  List<String> images;

  Products(
      {this.id,
      this.sku,
      this.categoryId,
      this.name,
      this.description,
      this.image,
      this.stock,
      this.cogs,
      this.price,
      this.specialPrice,
      this.isWholesale,
      this.isVariant,
      this.rating,
      this.sold,
      this.weight,
      this.length,
      this.width,
      this.height,
      this.weightMetricId,
      this.volumeMetricId,
      this.slug,
      this.warrantyId,
      this.point,
      this.redeemable,
      this.createdAt,
      this.updatedAt,
      this.productId,
      this.cName,
      this.category,
      this.wName,
      this.mwName,
      this.mvName,
      this.variantGroups,
      this.images});
  factory Products.fromJson(Map<String, dynamic> json) {
    List variantGroups = [];
    if (json['variant_groups'] != null) {
      variantGroups = <VariantGroups>[];
      json['variant_groups'].forEach((v) {
        variantGroups.add(new VariantGroups.fromJson(v));
      });
    }
    return Products(
      id: json['id'],
      sku: json['sku'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      stock: json['stock'],
      cogs: json['cogs'],
      price: json['price'],
      specialPrice: json['special_price'],
      isWholesale: json['is_wholesale'],
      isVariant: json['is_variant'],
      rating: json['rating'],
      sold: json['sold'],
      weight: json['weight'],
      length: json['length'],
      width: json['width'],
      height: json['height'],
      weightMetricId: json['weight_metric_id'],
      volumeMetricId: json['volume_metric_id'],
      slug: json['slug'],
      warrantyId: json['warranty_id'],
      point: json['point'],
      redeemable: json['redeemable'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      productId: json['product_id'],
      cName: json['cName'],
      category: json['category'],
      wName: json['wName'],
      mwName: json['mwName'],
      mvName: json['mvName'],
      variantGroups: variantGroups,
      images: json['images'].cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sku'] = this.sku;
    data['category_id'] = this.categoryId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['stock'] = this.stock;
    data['cogs'] = this.cogs;
    data['price'] = this.price;
    data['special_price'] = this.specialPrice;
    data['is_wholesale'] = this.isWholesale;
    data['is_variant'] = this.isVariant;
    data['rating'] = this.rating;
    data['sold'] = this.sold;
    data['weight'] = this.weight;
    data['length'] = this.length;
    data['width'] = this.width;
    data['height'] = this.height;
    data['weight_metric_id'] = this.weightMetricId;
    data['volume_metric_id'] = this.volumeMetricId;
    data['slug'] = this.slug;
    data['warranty_id'] = this.warrantyId;
    data['point'] = this.point;
    data['redeemable'] = this.redeemable;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['product_id'] = this.productId;
    data['cName'] = this.cName;
    data['category'] = this.category;
    data['wName'] = this.wName;
    data['mwName'] = this.mwName;
    data['mvName'] = this.mvName;
    if (this.variantGroups != null) {
      data['variant_groups'] =
          this.variantGroups.map((v) => v.toJson()).toList();
    }
    data['images'] = this.images;
    return data;
  }
}

class VariantGroups {
  String id;
  String name;
  String isRequired;
  List<Variants> variants;

  VariantGroups({this.id, this.name, this.isRequired, this.variants});

  VariantGroups.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isRequired = json['is_required'];
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants.add(new Variants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['is_required'] = this.isRequired;
    if (this.variants != null) {
      data['variants'] = this.variants.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Variants {
  String id;
  String name;
  String stock;
  String price;

  Variants({this.id, this.name, this.stock, this.price});

  Variants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    stock = json['stock'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['stock'] = this.stock;
    data['price'] = this.price;
    return data;
  }
}
