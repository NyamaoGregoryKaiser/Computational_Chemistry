# biomass_derivatives.py

# Function to compute the derivatives of the biomass system
def biomass_derivatives(t, values):
    # Unpack the current values of biomass in humus, dead trees, and living trees
    x, y, z = values
    
    # Compute the derivatives according to the given equations
    dxdt = -x + 3 * y
    dydt = -3 * y + 5 * z
    dzdt = -5 * z
    
    # Return the derivatives as a list
    return [dxdt, dydt, dzdt]

# Example test
if __name__ == "__main__":
    # Initial values of x, y, z
    x0 = 0
    y0 = 0
    z0 = 809601  # Initial biomass for living trees in thousands of tons

    # Time at t = 0
    t = 0

    # Calculate the derivatives at t=0
    derivatives = biomass_derivatives(t, [x0, y0, z0])

    # Print the results
    print(f"dx/dt = {derivatives[0]}")
    print(f"dy/dt = {derivatives[1]}")
    print(f"dz/dt = {derivatives[2]}")
