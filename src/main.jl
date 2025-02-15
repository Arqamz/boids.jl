using GLMakie
using Random
using StaticArrays

width, height = 800, 600

gravity = -0.1
damping = 0.99

n_balls = 2

positions = [MVector{2, Float32}(rand() * width, rand() * height) for _ in 1:n_balls]
velocities = [MVector{2, Float32}(rand() * 10 - 5, rand() * 10 - 5) for _ in 1:n_balls]

obs_positions = Observable(positions)
obs_velocities = Observable(velocities)

fig = Figure(resolution = (width, height))
ax = Axis(fig[1, 1], title = "Bouncing Boids", aspect = DataAspect())

balls = scatter!(ax, [p[1] for p in obs_positions[]], [p[2] for p in obs_positions[]]; marker = :circle, color = :red, markersize = 20)

xlims!(ax, 0, width)
ylims!(ax, 0, height)

function step_simulation!(positions, velocities)
    for i in 1:n_balls

        velocities[i][2] += gravity
        
        positions[i] .+= velocities[i]
        
        if positions[i][1] < 0 || positions[i][1] > width
            velocities[i][1] *= -1
        end

        if positions[i][2] < 0 || positions[i][2] > height
            velocities[i][2] *= -1
        end
    end
end

function update_simulation()
    step_simulation!(obs_positions[], obs_velocities[])
    obs_positions[] = obs_positions[]
end

@async begin
    while true
        update_simulation()
        sleep(0.04)
    end
end

display(fig)

