function [circle_params, fval, rms] = davinciFit3dCircle(pt_mat)
% circle params: x, y, z, r
% pt_mat should be nx3

% TODO open toggle plotting

%% Extracting 3 random pts from mat to find an initial circle in 3d space
mat_size = size(pt_mat, 1);

x_mat = pt_mat(:,1);
y_mat = pt_mat(:,2);
z_mat = pt_mat(:,3);

% Must NOT take the same points again
rnd = randperm(mat_size,3);
init_pt_1 =  pt_mat(rnd(1),:);
init_pt_2 =  pt_mat(rnd(2),:);
init_pt_3 =  pt_mat(rnd(3),:);

[init_center,init_rad,init_v1n,init_v2nb] = circlefit3d(init_pt_1,init_pt_2,init_pt_3);


%% Constructing fmin function for 3d circle

circle_fitting_error = @(a) (...
    transpose(x_mat - ones(mat_size,1)*[a(1)]) * (x_mat - ones(mat_size,1)*[a(1)]) + ...
    transpose(y_mat - ones(mat_size,1)*[a(2)]) * (y_mat - ones(mat_size,1)*[a(2)]) + ...
    transpose(z_mat - ones(mat_size,1)*[a(3)]) * (z_mat - ones(mat_size,1)*[a(3)]) + ...
    - mat_size * a(4) * a(4))/mat_size

lb = [-1, -1, -1, 0.1];
ub = [1, 1, 1, 0.5];
a0 = [init_center(1), init_center(2), init_center(3), init_rad];
A= [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];
size_max = 3000000;
options = optimoptions('fmincon','MaxFunctionEvaluations',size_max,'MaxIterations',100000);

[a, fval] = fmincon(circle_fitting_error,a0,A,b,Aeq,beq,lb,ub,nonlcon,options);


%% Output check

circle_params = a;

%% rms
err_sum = 0;
for i = 1:mat_size
    
    err_sum = err_sum + abs((x_mat(i) - circle_params(1))^2 + (y_mat(i) - circle_params(2))^2 + ...
        (z_mat(i) - circle_params(3))^2 - (circle_params(4))^2);
        
end % for loop

rms = sqrt(err_sum/mat_size);



end