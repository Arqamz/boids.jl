using GLMakie

# Define the Lorenz system
Base.@kwdef mutable struct Lorenz
    dt::Float64 = 0.01
    σ::Float64 = 10
    ρ::Float64 = 28
    β::Float64 = 8/3
    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1
end

# Function to take one step of the Lorenz system
function step!(l::Lorenz)
    dx = l.σ * (l.y - l.x)
    dy = l.x * (l.ρ - l.z) - l.y
    dz = l.x * l.y - l.β * l.z
    l.x += l.dt * dx
    l.y += l.dt * dy
    l.z += l.dt * dz
    Point3f(l.x, l.y, l.z)
end

# Create an instance of the Lorenz system
attractor = Lorenz()

# Define the initial state of the plot
points = Observable(Point3f[])
colors = Observable(Int[])

# Set up the theme and figure for the plot
set_theme!(theme_black())
fig, ax, l = lines(points, color = colors,
    colormap = :inferno, transparency = true,
    axis = (; type = Axis3, protrusions = (0, 0, 0, 0),
              viewmode = :fit, limits = (-30, 30, -30, 30, 0, 50)))

# Display the figure to start rendering
display(fig)

# Main loop for live rendering
for frame in 1:120
    # Update the Lorenz attractor by adding new points
    for i in 1:50
        push!(points[], step!(attractor))
        push!(colors[], frame)
    end
    
    # Dynamically update the azimuth for camera rotation
    ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame / 120)
    
    # Notify the plot to update with the new points and colors
    notify(points)
    notify(colors)
    
    # Update the color range based on the frame
    l.colorrange = (0, frame)
    
    # Add a small delay to control the animation speed
    sleep(0.1)
end

