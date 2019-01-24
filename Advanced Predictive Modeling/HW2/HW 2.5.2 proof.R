# Proof of what I'm saying for APM HW2 #5.2

# Load in the mtcars data because when you Google PCA in R, 
# this is the example
df <- mtcars
mtcars.pca <- prcomp(mtcars[,c(1:7,10,11)], center = TRUE, scale. = TRUE)
mtcars.pca$rotation

# From summary(mtcars.pca), place the prop of variance into eigenvalues
# because my intuition tells me that the prop of variance is what
# each eigenvalue represents.
eigenvalues <- c(0.6284, 0.2313, 0.05602, 0.02945, 0.02035, 0.01375, 0.01167, 0.0065, 0.00247)
summary(mtcars.pca)

# Place the eigenvalues into diagonal matrix D
value_matrix <- diag(x=eigenvalues, 9, 9)

# Save the loadings as matrix V
vector_matrix <- mtcars.pca$rotation

# Save the data used as a matrix called data. This is matrix X.
data <- as.matrix(mtcars[,c(1:7,10,11)])

# The forumula is cov(X) = X^X = VDV^

# Get the left side of the equation
b = scale(data) # We scaled the data in prcomp, so we need to scale here
left <- cov(b)

# Get the right side of the equation
right <- vector_matrix %*% value_matrix %*% t(vector_matrix)

# Proof of the equation
left     #  1.0000000  -0.8521620  -0.8475514   -0.7761684  0.68117191   -0.8676594
right    # 0.11110199 -0.09467965 -0.09416712  -0.08623611  0.07568105  -0.09640056
right*9  #  0.9999179  -0.8521168  -0.8475041   -0.7761250  0.68112948   -0.8676050

# Okay, so left is equal to right only when right is multiplied by 9.
# Numbers are slightly off only because we rounded when defining the
# eigenvalues. But why 9? This is because this is the number of components.
# Remember the cov of identical columns is 1, so the sum of the diagonals
# is exactly 9 for the 9 features in the X matrix. Since our eigenvalue
# matrix corresponds to the percentage of variance explained, the sum of
# the diagonal here is restricted to 1. Therefore, the eigenvalue matrix
# isn't the matrix that is the % variance explained, but rather that number
# multiplied by the number of principle components.