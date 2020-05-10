function show_particles(X, Y_k)

figure(1);
Y_k = hsv2rgb(Y_k);
imshow(Y_k)

title('+++ Showing Particles +++')

hold on
% remember that this time original point is at left top and (x,y) is (column,row)
plot(X(2,:), X(1,:), '.')
hold off

drawnow
