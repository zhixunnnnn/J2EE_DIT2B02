package Assignment1.Service;

public class Service {
    private int serviceId;
    private int categoryId;
    private String serviceName;
    private String description;
    private double price;
    private int durationMin;
    private String imagePath;

    // No-arg constructor (required for JSON-B)
    public Service() {}

    // All-args constructor (optional, can still keep for manual creation)
    public Service(int serviceId, int categoryId, String serviceName, String description,
                   double price, int durationMin, String imagePath) {
        this.serviceId = serviceId;
        this.categoryId = categoryId;
        this.serviceName = serviceName;
        this.description = description;
        this.price = price;
        this.durationMin = durationMin;
        this.imagePath = imagePath;
    }

    // Getters
    public int getServiceId() { return serviceId; }
    public int getCategoryId() { return categoryId; }
    public String getServiceName() { return serviceName; }
    public String getDescription() { return description; }
    public double getPrice() { return price; }
    public int getDurationMin() { return durationMin; }
    public String getImagePath() { return imagePath; }

    // Setters (required for JSON-B deserialization)
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
    public void setDescription(String description) { this.description = description; }
    public void setPrice(double price) { this.price = price; }
    public void setDurationMin(int durationMin) { this.durationMin = durationMin; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    @Override
    public String toString() {
        return "Service{" +
                "serviceId=" + serviceId +
                ", categoryId=" + categoryId +
                ", serviceName='" + serviceName + '\'' +
                ", description='" + description + '\'' +
                ", price=" + price +
                ", durationMin=" + durationMin +
                ", imagePath='" + imagePath + '\'' +
                '}';
    }
}
