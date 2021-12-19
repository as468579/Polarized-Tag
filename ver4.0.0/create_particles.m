function particles = create_particles(resolution, scale_range, numOfParticles)
    x_pos = randi(resolution(2), 1, numOfParticles);
    y_pos = randi(resolution(1), 1, numOfParticles);
    delta_x = zeros(1, numOfParticles);
    delta_y = zeros(1, numOfParticles);
    angle = randi([0, 359], 1, numOfParticles);
    delta_angle = zeros(1, numOfParticles);
    scale = randi( scale_range, 1, numOfParticles);
    delta_scale = zeros(1, numOfParticles);
    numOfComponents = repelem(-1, 1, numOfParticles);
    id = repelem(-1, 1, numOfParticles);
    particles = [x_pos; y_pos; delta_x; delta_y; angle; delta_angle; scale; delta_scale; numOfComponents; id];
end