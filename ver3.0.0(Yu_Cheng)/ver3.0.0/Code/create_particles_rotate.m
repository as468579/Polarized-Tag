function X = create_particles_rotate(Npix_resolution, scaling_range, Npop_particles,legalParticleLocation)
if nargin  == 3
    X1 = randi(Npix_resolution(2), 1, Npop_particles);
    X2 = randi(Npix_resolution(1), 1, Npop_particles);
    X3 = zeros(2, Npop_particles);
    X4 = randi([0,359],1,Npop_particles);
    X5 = zeros(1,Npop_particles);
    X6 = randi([scaling_range(1),scaling_range(2)],1,Npop_particles);
    X7 = zeros(1,Npop_particles);
    X = [X1; X2; X3; X4; X5; X6; X7];
elseif nargin == 4
    ind1 = randi(size(legalParticleLocation,2), 1, Npop_particles);
    X1 = legalParticleLocation(1,ind1);
    X2 = legalParticleLocation(2,ind1);
    X3 = zeros(2, Npop_particles);
    % theta 
    X4 = randi([-179,179],1,Npop_particles);
    
    % delta theta
    X5 = zeros(1,Npop_particles);
    
    % scalar
    X6 = randi([scaling_range(1),scaling_range(2)],1,Npop_particles);
    
    % delta scalar
    X7 = zeros(1,Npop_particles);
    X = [X1; X2; X3; X4; X5; X6; X7];
end