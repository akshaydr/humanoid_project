%% Initialize
run("robotParameters.m");
run("Robot_leg_2_DataFile.m");

%% Inputs
upper_leg_length = 13.5; %Upper Leg Length
lower_leg_length = 21.5; %Lower Leg Length
bend = 4;
step_length = 10; %Step Length
gait_period = 1.0; %Gait Period
samples = 20; %

simulation_time = linspace(0,10, samples*2);

%% Trajectory Parameters
h = 0; %Parabola Transformation
time = linspace(0,gait_period, samples*2);
time_first = linspace(0,gait_period, samples);
total_time = linspace(0,10, samples*2);
u1 = linspace(0, 10, samples*2);

%% Trajectory Generation
x = linspace(h, h+step_length, samples);
x_first = linspace(h, h, samples);
%y1 = trajectory_equation(step_length, samples);
y1 = trajectory_equation(0,0,  step_length/2,step_length/4,  step_length,0, h,samples);
y2 = trajectory_equation(0,0,  step_length/2,0,  step_length,0, h,samples);
y3 = trajectory_equation(0,0,  0.01,step_length/8,  0.02,step_length/4, h,samples);

%% Inverse Kinematics Generaion
%(x_trajectory, y_trajectory, link1, link2, x_link_position, y_link_position)
m = 0;
n = upper_leg_length + lower_leg_length - bend;
[right_hip_1, right_knee_1] = joint_angles(x, y1, upper_leg_length, lower_leg_length, m, n, samples);
hold on
plot(x,right_hip_1,'LineWidth',3,'color',[1,0.5,0]);  %Orange
plot(x,right_knee_1,'LineWidth',3,'color',[0,0.5,0]);  %Green
hold off
[right_hip_2, right_knee_2] = joint_angles(x, y2, upper_leg_length, lower_leg_length, m, n, samples);
[right_hip_3, right_knee_3] = joint_angles(x_first, y3, upper_leg_length, lower_leg_length, m, n, samples);

[left_hip_1, left_knee_1] = joint_angles(x, y1, upper_leg_length, lower_leg_length, m, n, samples);
[left_hip_2, left_knee_2] = joint_angles(x, y2, upper_leg_length, lower_leg_length, m, n, samples);
[left_hip_3, left_knee_3] = joint_angles(x, y2, upper_leg_length, lower_leg_length, m, n, samples);

%% CoM shift angle calculation
xg = 10.72;
yg = 9.2;
t4 = atand(xg/(34.5 + yg));

%xg = 7.72;
%yg = 9.2;
%t4 = atand(xg/(34.5 + yg));
%% Right Leg joints
right_hip_1 = right_hip_1 + smiData.RevoluteJoint(2).Rz.Pos + 270;
right_hip_2 = right_hip_2 + smiData.RevoluteJoint(2).Rz.Pos + 270;
right_hip_3 = right_hip_3 + smiData.RevoluteJoint(2).Rz.Pos + 270;
right_hip_first = [right_hip_3 flip(right_hip_3)];
right_hip = [right_hip_2 flip(right_hip_1) ];
%right_hip = [flip(right_hip_1) right_hip_2];

right_knee_1 = smiData.RevoluteJoint(1).Rz.Pos - right_knee_1;
right_knee_2 = smiData.RevoluteJoint(1).Rz.Pos - right_knee_2;
right_knee_3 = smiData.RevoluteJoint(1).Rz.Pos - right_knee_3;
right_knee_first = [right_knee_3 flip(right_knee_3)];
right_knee = [right_knee_2 flip(right_knee_1) ];
%right_knee = [flip(right_knee_1) right_knee_2];

right_ankle_first = right_hip_first - right_knee_first + smiData.RevoluteJoint(3).Rz.Pos;
right_ankle = right_hip - right_knee + smiData.RevoluteJoint(3).Rz.Pos;

right_knee_twist_1 = linspace(smiData.RevoluteJoint(8).Rz.Pos, +t4 + smiData.RevoluteJoint(8).Rz.Pos, 10);
right_knee_twist_2 = linspace(smiData.RevoluteJoint(8).Rz.Pos, smiData.RevoluteJoint(8).Rz.Pos, 0);
right_knee_twist_3 = linspace(smiData.RevoluteJoint(8).Rz.Pos + t4, smiData.RevoluteJoint(8).Rz.Pos, 10);
right_knee_twist_4 = linspace(smiData.RevoluteJoint(8).Rz.Pos, smiData.RevoluteJoint(8).Rz.Pos, samples);
right_knee_twist = [right_knee_twist_1 right_knee_twist_2 right_knee_twist_3 right_knee_twist_4];

right_abduction_1 = linspace(smiData.RevoluteJoint(5).Rz.Pos, -t4 + smiData.RevoluteJoint(5).Rz.Pos, 10);
right_abduction_2 = linspace(smiData.RevoluteJoint(5).Rz.Pos, smiData.RevoluteJoint(5).Rz.Pos, 0);
right_abduction_3 = linspace(smiData.RevoluteJoint(5).Rz.Pos - t4, smiData.RevoluteJoint(5).Rz.Pos, 10);
right_abduction_4 = linspace(smiData.RevoluteJoint(5).Rz.Pos, smiData.RevoluteJoint(5).Rz.Pos, samples);
right_abduction = [right_abduction_1 right_abduction_2 right_abduction_3 right_abduction_4];

%right_hip = linspace(smiData.RevoluteJoint(2).Rz.Pos,smiData.RevoluteJoint(2).Rz.Pos, samples*2);
%right_knee = linspace(smiData.RevoluteJoint(1).Rz.Pos,smiData.RevoluteJoint(1).Rz.Pos, samples*2);
%right_ankle = linspace(smiData.RevoluteJoint(3).Rz.Pos,smiData.RevoluteJoint(3).Rz.Pos, samples*2);
%right_knee_twist = linspace(smiData.RevoluteJoint(8).Rz.Pos,smiData.RevoluteJoint(8).Rz.Pos, samples*2);
%right_abduction = linspace(smiData.RevoluteJoint(5).Rz.Pos,smiData.RevoluteJoint(5).Rz.Pos, samples*2);

right_t6 = linspace(smiData.RevoluteJoint(10).Rz.Pos,smiData.RevoluteJoint(10).Rz.Pos, samples*2);

right_theta_init_1 = deg2rad(linspace(smiData.RevoluteJoint(2).Rz.Pos, smiData.RevoluteJoint(2).Rz.Pos, samples*2));
right_theta_init_2 = deg2rad(linspace(smiData.RevoluteJoint(1).Rz.Pos, smiData.RevoluteJoint(1).Rz.Pos, samples*2));
right_theta_init_3 = deg2rad(linspace(smiData.RevoluteJoint(3).Rz.Pos, smiData.RevoluteJoint(3).Rz.Pos, samples*2));
right_theta_init_4 = deg2rad(linspace(smiData.RevoluteJoint(8).Rz.Pos, smiData.RevoluteJoint(8).Rz.Pos, samples*2));
right_theta_init_5 = deg2rad(linspace(smiData.RevoluteJoint(5).Rz.Pos, smiData.RevoluteJoint(5).Rz.Pos, samples*2));
right_theta_init_6 = deg2rad(linspace(smiData.RevoluteJoint(10).Rz.Pos, smiData.RevoluteJoint(10).Rz.Pos, samples*2));

right_theta_pos_1 = deg2rad(linspace(smiData.RevoluteJoint(2).Rz.Pos, right_hip_1(1), samples*2));
right_theta_pos_2 = deg2rad(linspace(smiData.RevoluteJoint(1).Rz.Pos, right_knee_1(1), samples*2));
right_theta_pos_3 = deg2rad(linspace(smiData.RevoluteJoint(3).Rz.Pos, right_ankle(1), samples*2));
right_theta_pos_4 = deg2rad(linspace(smiData.RevoluteJoint(8).Rz.Pos, smiData.RevoluteJoint(8).Rz.Pos , samples*2));
right_theta_pos_5 = deg2rad(linspace(smiData.RevoluteJoint(5).Rz.Pos, smiData.RevoluteJoint(5).Rz.Pos , samples*2));
right_theta_pos_6 = deg2rad(linspace(smiData.RevoluteJoint(10).Rz.Pos, smiData.RevoluteJoint(10).Rz.Pos , samples*2));

right_theta_first_1 = deg2rad(right_hip_first);
right_theta_first_2 = deg2rad(right_knee_first);
right_theta_first_3 = deg2rad(right_ankle_first);
right_theta_first_4 = deg2rad(linspace(smiData.RevoluteJoint(8).Rz.Pos, smiData.RevoluteJoint(8).Rz.Pos , samples*2));
right_theta_first_5 = deg2rad(linspace(smiData.RevoluteJoint(5).Rz.Pos, smiData.RevoluteJoint(5).Rz.Pos , samples*2));
right_theta_first_6 = deg2rad(linspace(smiData.RevoluteJoint(10).Rz.Pos, smiData.RevoluteJoint(10).Rz.Pos , samples));

right_theta_1 = deg2rad(right_hip);
right_theta_2 = deg2rad(right_knee);
right_theta_3 = deg2rad(right_ankle);
right_theta_4 = deg2rad(right_knee_twist);
right_theta_5 = deg2rad(right_abduction);
right_theta_6 = deg2rad(right_t6);

%% Left Leg joints
hip = (left_hip_1) + 270;
hip = (4000/360)* hip;
hip = int32(hip + 2036);
left_hip_1 = left_hip_1 + smiData.RevoluteJoint(12).Rz.Pos + 270;
left_hip_2 = left_hip_2 + smiData.RevoluteJoint(12).Rz.Pos + 270;
left_hip_3 = left_hip_3 + smiData.RevoluteJoint(12).Rz.Pos + 270;
left_hip = [flip(left_hip_1) left_hip_2];
%left_hip = [left_hip_2 flip(left_hip_1)];

kn = (left_knee_1) * -1;
kn = (4000/360)* kn ;
kn = int32(kn +2036);
left_knee_1 = smiData.RevoluteJoint(11).Rz.Pos - left_knee_1;
left_knee_2 = smiData.RevoluteJoint(11).Rz.Pos - left_knee_2;
left_knee_3 = smiData.RevoluteJoint(11).Rz.Pos - left_knee_3;
left_knee = [flip(left_knee_1) left_knee_2];
%left_knee = [left_knee_2 flip(left_knee_1)];

left_ankle_3 = left_hip_3 - left_knee_3 + smiData.RevoluteJoint(7).Rz.Pos;
left_ankle = left_hip - left_knee + smiData.RevoluteJoint(7).Rz.Pos;

left_knee_twist_1 = linspace(smiData.RevoluteJoint(6).Rz.Pos, smiData.RevoluteJoint(6).Rz.Pos, samples);
left_knee_twist_2 = linspace(smiData.RevoluteJoint(6).Rz.Pos, -t4 + smiData.RevoluteJoint(6).Rz.Pos, 10);
left_knee_twist_3 = linspace(smiData.RevoluteJoint(6).Rz.Pos, smiData.RevoluteJoint(6).Rz.Pos, 0);
left_knee_twist_4 = linspace(smiData.RevoluteJoint(6).Rz.Pos - t4, smiData.RevoluteJoint(6).Rz.Pos, 10);
left_knee_twist = [left_knee_twist_1 left_knee_twist_2 left_knee_twist_3 left_knee_twist_4];

left_abduction_1 = linspace(smiData.RevoluteJoint(4).Rz.Pos, smiData.RevoluteJoint(4).Rz.Pos, samples);
left_abduction_2 = linspace(smiData.RevoluteJoint(4).Rz.Pos, t4 + smiData.RevoluteJoint(4).Rz.Pos, 10);
left_abduction_3 = linspace(smiData.RevoluteJoint(4).Rz.Pos, smiData.RevoluteJoint(4).Rz.Pos, 0);
left_abduction_4 = linspace(smiData.RevoluteJoint(4).Rz.Pos + t4, smiData.RevoluteJoint(4).Rz.Pos, 10);
left_abduction = [left_abduction_1 left_abduction_2 left_abduction_3 left_abduction_4];

left_knee_twist_first_1 = linspace(smiData.RevoluteJoint(6).Rz.Pos, -t4 + smiData.RevoluteJoint(6).Rz.Pos, 20);
left_knee_twist_first_2 = linspace(smiData.RevoluteJoint(6).Rz.Pos - t4, smiData.RevoluteJoint(6).Rz.Pos, 20);
left_knee_twist_first = [left_knee_twist_first_1 left_knee_twist_first_2];

left_abduction_first_1 = linspace(smiData.RevoluteJoint(4).Rz.Pos, t4 + smiData.RevoluteJoint(4).Rz.Pos, 20);
left_abduction_first_2 = linspace(smiData.RevoluteJoint(4).Rz.Pos + t4, smiData.RevoluteJoint(4).Rz.Pos, 20);
left_abduction_first = [left_abduction_first_1 left_abduction_first_2];

%left_hip = linspace(smiData.RevoluteJoint(12).Rz.Pos,smiData.RevoluteJoint(12).Rz.Pos, samples*2);
%left_knee = linspace(smiData.RevoluteJoint(11).Rz.Pos,smiData.RevoluteJoint(11).Rz.Pos, samples*2);
%left_ankle = linspace(smiData.RevoluteJoint(7).Rz.Pos,smiData.RevoluteJoint(7).Rz.Pos, samples*2);
%left_knee_twist = linspace(smiData.RevoluteJoint(6).Rz.Pos,smiData.RevoluteJoint(6).Rz.Pos, samples*2);
%left_abduction = linspace(smiData.RevoluteJoint(4).Rz.Pos,smiData.RevoluteJoint(4).Rz.Pos, samples*2);

left_t6 = linspace(smiData.RevoluteJoint(9).Rz.Pos,smiData.RevoluteJoint(9).Rz.Pos, samples*2);

left_theta_init_1 = deg2rad(linspace(smiData.RevoluteJoint(12).Rz.Pos, smiData.RevoluteJoint(12).Rz.Pos, samples*2));
left_theta_init_2 = deg2rad(linspace(smiData.RevoluteJoint(11).Rz.Pos, smiData.RevoluteJoint(11).Rz.Pos, samples*2));
left_theta_init_3 = deg2rad(linspace(smiData.RevoluteJoint(7).Rz.Pos, smiData.RevoluteJoint(7).Rz.Pos, samples*2));
left_theta_init_4 = deg2rad(linspace(smiData.RevoluteJoint(6).Rz.Pos, smiData.RevoluteJoint(6).Rz.Pos, samples*2));
left_theta_init_5 = deg2rad(linspace(smiData.RevoluteJoint(4).Rz.Pos, smiData.RevoluteJoint(4).Rz.Pos, samples*2));
left_theta_init_6 = deg2rad(linspace(smiData.RevoluteJoint(9).Rz.Pos, smiData.RevoluteJoint(9).Rz.Pos, samples*2));

left_theta_pos_1 = deg2rad(linspace(smiData.RevoluteJoint(12).Rz.Pos, left_hip_1(1), samples*2));
left_theta_pos_2 = deg2rad(linspace(smiData.RevoluteJoint(11).Rz.Pos, left_knee_1(1), samples*2));
left_theta_pos_3 = deg2rad(linspace(smiData.RevoluteJoint(7).Rz.Pos, left_ankle(20), samples*2));
left_theta_pos_4 = deg2rad(linspace(smiData.RevoluteJoint(6).Rz.Pos, smiData.RevoluteJoint(6).Rz.Pos, samples*2));
left_theta_pos_5 = deg2rad(linspace(smiData.RevoluteJoint(4).Rz.Pos, smiData.RevoluteJoint(4).Rz.Pos, samples*2));
left_theta_pos_6 = deg2rad(linspace(smiData.RevoluteJoint(9).Rz.Pos, smiData.RevoluteJoint(9).Rz.Pos, samples*2));

left_theta_first_1 = deg2rad(left_hip_3);
left_theta_first_2 = deg2rad(left_knee_3);
left_theta_first_3 = deg2rad(left_ankle_3);
left_theta_first_4 = deg2rad(left_knee_twist_first);
left_theta_first_5 = deg2rad(left_abduction_first);
left_theta_first_6 = deg2rad(linspace(smiData.RevoluteJoint(9).Rz.Pos, smiData.RevoluteJoint(9).Rz.Pos, samples));

left_theta_1 = deg2rad(left_hip);
left_theta_2 = deg2rad(left_knee);
left_theta_3 = deg2rad(left_ankle);
left_theta_4 = deg2rad(left_knee_twist);
left_theta_5 = deg2rad(left_abduction);
left_theta_6 = deg2rad(left_t6);

%% Graph Plot
% hold on
% plot(x,hip,'LineWidth',3,'color',[1,0.5,0]);  %Orange
% plot(x,kn,'LineWidth',3,'color',[0,0.5,0]);  %Green
% hold off

%% Joint angle generation Function
function [t1, t2] = joint_angles(x, y, l1, l2, m, n, samples)
t2_numerator = ((x-m).^2 + (y-n).^2 - l1^2 - l2^2);
t2_denominator = (2 * l1 * l2);
t2 = acosd(t2_numerator./t2_denominator);

t1_numerator = l2 * sind(t2);
t1_denominator = l1 + (l2 * cosd(t2));
t1 = atand((y-n)./(x-m)) - atand(t1_numerator./t1_denominator);
t1((2*m) + 1 : samples) = t1((2*m) + 1 : samples) + 180;

t2 = -t2;
t1 = -180 -t1;
end

%% Trajectory function
function y = trajectory_equation(xi,yi, xm,ym, xf,yf, h,samples)
syms a b c;
eqn1 = c == yi;
eqn2 = ym == ((xm^2)*a + (xm*b) + c);
eqn3 = yf == ((xf^2)*a + (xf*b) + c);
[A,B] = equationsToMatrix([eqn1, eqn2, eqn3], [c, b, a]);
co_effs = linsolve(A,B);
x = linspace(h, h+xf, samples);
y = double((co_effs(3)*((x-h).^2)) + (co_effs(2)*(x-h)) + co_effs(1));
end
