function show_particles(X, Y_k)

figure(1);
Y_k = hsv2rgb(Y_k);
imshow(Y_k);
text(1200, 1,  'CPU ver3.0.0', 'HorizontalAlignment','right','VerticalAlignment','top', 'FontSize',20,'Color', 'w');
% title('+++ Showing Particles +++');

hold on
plot(X(2,:), X(1,:), '.');
hold off

drawnow
