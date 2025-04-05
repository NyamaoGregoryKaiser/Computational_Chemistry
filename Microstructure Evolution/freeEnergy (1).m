clear all
clc

phi = linspace(0,1,101);

omg = 2.5;
w = 1;

% regular solution double well energy function
RSF = w*(omg*phi.*(1-phi) + phi.*log(phi) + (1-phi).*log(1-phi));

figure(6)
plot(phi, RSF, 'LineWidth', 2)
grid on


% chemical potential (first derivative of energy function)
dF = log(phi) - log(1-phi) - w*(omg*phi - omg*(1 - phi));

figure(2)
plot(phi,dF, 'LineWidth', 2)
grid on

% derivative of chemical potential (2nd derivative of energy)
ddF = 1./phi + 1./(1 -phi) -2*w*omg;

figure(3)
plot(phi,ddF, 'LineWidth', 2)
grid on
