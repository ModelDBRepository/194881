function Pos = estimatePosition(Th, X,Y, opt)
% estimatePosition
%   Th  - Allo-centric azimuth angles for all visible points on walls.
%   X   - X-coordiante of memorized landmarks on walls.
%   Y   - Y-coordinate of memorized landmarks on walls.
%   opt - Structure with fields:
%         w - width of the cage, which references x-coordinates.
%         l - length of the cage, which references y-coordinates.
%
% RETURN
%   Pos - Estimated position with (x,y)-coordinates.
%
% DESCRIPTION
%   This method works only in 2D, assuming all points are projected into a
%   plane parallel to the ground.
%   The method uses additional constraints about the width, length of the 
%   box to estimate the x,y compression factors and the position of self.
%
%   Copyright (C) 2015  Florian Raudies, 04/29/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.


X = X(:)';
Y = Y(:)';

% Get the width and length of the box, and the regularization parameter.
w           = opt.w;
l           = opt.l;
a           = opt.alpha;
aC          = 1 - a;

% Define the indices for the top, bottom, left, and right wall.
IndexTop    = abs(Y-l/2) <= eps('single');
IndexBottom = abs(Y+l/2) <= eps('single');
IndexRight  = abs(X-w/2) <= eps('single');
IndexLeft   = abs(X+w/2) <= eps('single');

% Auxiliary variables for the top/bottom/left/right wall.
ThK         = Th(IndexTop);
XK          = X(IndexTop);
YK          = Y(IndexTop);
CosK        = cos(ThK);
SinK        = sin(ThK);
TanK        = tan(ThK);

ThL         = Th(IndexBottom);
XL          = X(IndexBottom);
YL          = Y(IndexBottom);
CosL        = cos(ThL);
SinL        = sin(ThL);
TanL        = tan(-ThL);

ThMu        = Th(IndexLeft);
XMu         = X(IndexLeft);
YMu         = Y(IndexLeft);
CosMu       = cos(ThMu);
SinMu       = sin(ThMu);
TanMu       = tan(ThMu-pi/2);

ThNu        = Th(IndexRight);
XNu         = X(IndexRight);
YNu         = Y(IndexRight);
CosNu       = cos(ThNu);
SinNu       = sin(ThNu);
TanNu       = tan(-ThNu-pi/2);

% Merge auxiliary variables from top/bottom wall and left/right wall.
XKL         = [XK(:);       XL(:)];
YKL         = [YK(:);       YL(:)];
XMuNu       = [XMu(:);      XNu(:)];
YMuNu       = [YMu(:);      YNu(:)];
SinKL       = [SinK(:);     SinL(:)];
SinMuNu     = [SinMu(:);    SinNu(:)];
CosKL       = [CosK(:);     CosL(:)];
CosMuNu     = [CosMu(:);    CosNu(:)];

% All combinations of top/bottom and left/rigth points on walls.
[TanK TanL]     = ndgrid(TanK, TanL);
[XK XL]         = ndgrid(XK, XL);
[TanMu TanNu]   = ndgrid(TanMu, TanNu);
[YMu YNu]       = ndgrid(YMu, YNu);
TanK            = TanK(:);
TanL            = TanL(:);
XK              = XK(:);
XL              = XL(:);
TanMu           = TanMu(:);
TanNu           = TanNu(:);
YMu             = YMu(:);
YNu             = YNu(:);

m11 = aC*mean(1-CosKL.^2) + a*mean((TanK+TanL).^2) + aC*mean(1-CosMuNu.^2);
m12 = - aC*mean(CosKL.*SinKL) - aC*mean(CosMuNu.*SinMuNu);
m13 = aC*mean(-XMuNu + XMuNu.*CosMuNu.^2);
m14 = aC*mean(YKL.*CosKL.*SinKL) + a*l*mean(TanK+TanL);
m22 = aC*mean(1-SinMuNu.^2) + a*mean((TanMu+TanNu).^2) + aC*mean(1-SinKL.^2);
m23 = aC*mean(XMuNu.*CosMuNu.*SinMuNu) + a*w*mean(TanMu+TanNu);
m24 = aC*mean(-YKL+YKL.*SinKL.^2);
m33 = aC*mean(XMuNu.^2 - XMuNu.^2.*CosMuNu.^2) + a*w^2;
m34 = 0;
m44 = aC*mean(YKL.^2 - YKL.^2.*SinKL.^2) + a*l^2;
M = [m11 m12 m13 m14; ...
     m12 m22 m23 m24; ...
     m13 m23 m33 m34; ...
     m14 m24 m34 m44];

% Calculate the solution for the x,y coordinates and x,y compression
% factors.
X = M\[(aC*mean(XKL-XKL.*CosKL.^2) ...
            + a*mean((XK.*TanK+XL.*TanL).*(TanK+TanL)) ...
            - aC*mean(YMuNu.*CosMuNu.*SinMuNu)); ...
       (aC*mean(YMuNu-YMuNu.*SinMuNu.^2) ...
            + a*mean((YMu.*TanMu+YNu.*TanNu).*(TanMu+TanNu)) ...
            - aC*mean(XKL.*CosKL.*SinKL)); ...
       (aC*mean(XMuNu.*YMuNu.*CosMuNu.*SinMuNu) ...
            + a*w*mean(YMu.*TanMu + YNu.*TanNu)); ...
       (aC*mean(XKL.*YKL.*CosKL.*SinKL) ...
            + a*l*mean(XK.*TanK+XL.*TanL))];
        
% Scale the position of self by the corresponding compresion factors.
Pos(1) = X(1)/X(3);
Pos(2) = X(2)/X(4);
