height = 40;
width = 60;
a = randi(255, height, width);
[x, y] = meshgrid(1:width, 1:height); 


[qx, qy] = meshgrid(1.5:width, 1.5:height);
timer1 = tic;
a1 = interp2(x, y, a, qx, qy);
time1 = toc(timer1);

timer2 = tic;
a2 = qinterp2(x, y, a, qx, qy); 
time2 = toc(timer2);

[x, y] = ndgrid(1:height, 1:width);
[qxx, qyy] = ndgrid(1.5:height, 1.5:width);
timer3 = tic;
F = griddedInterpolant(x, y, a);
a3 = F(qx, qy); 
time3 = toc(timer3);

disp(all(a1 == a2, 'all'));
disp(all(a1 == a3, 'all'));