% [T, r, inl, Ti, ri] = laserCamCalib(Tp, Pl, rt, opt)
%
% BASIC USE:
%   T = laserCamCalib(Tp, Pl)
%
% Calibration between a laser range scanner (lrs) and a camera. Find rigid 
% transformation T from the the camera to the lrs reference frame,
% given N poses of a calibration checkerboard in the camera reference frame
% and the correspondent N sets of points with laser measurements of the 
% calibration checkerboard. This method includes a RANSAC step with 
% threshold rt, and non-linear optimization refinement.
%
% This is an implementation of the method proposed in:
%   Qilong Zhang; Pless, R.; , "Extrinsic calibration of a camera and laser
%   range finder (improves camera calibration)," IROS, 2004
% Additionally it was modified to include a robust estimator (RANSAC), for
% details see:
%   F. Vasconcelos, J.P. Barreto, and U. Nunes, "A Minimal Solution for the
%   Extrinsic Calibration of a Camera and a Laser-Rangefinder", IEEE TPAMI,
%   2012
%
% INPUT:
%   Tp     - calibibration plane poses in the camera reference frame 
%            (3x3xN matrix).
%   Pl     - 2D points detected by laser (1xN cell, with 2xMi matrices).
%   rt     - ransac treshold (default (recomended): 50)
%   opt    - optimization flag (1 - on (default), 0 - off).
%
% OUTPUT:
%   T   - optimized lrs-camera calibration.
%   r   - optimized residue of lrs depths.
%   inl - index of inlier calibration planes.
%   Ti  - initial lrs-camera calibration.
%   ri  - initial residue of lrs depths. 
%      
function [T, r, inl, Ti, ri] = lccZhang(Tp, Pl, rt, opt)

if ~exist('rt','var')
    rt = 50;
end

if ~exist('opt','var')
    opt = 1;
end

N     = length(Tp);
PIcam = nan(4,N);
L     = nan(6,N);

np = -reshape(Tp(1:3,3,:),3,N,1);
d  = sum(np.*reshape(Tp(1:3,4,:),3,N,1));

% CALIBRATION
disp('Initialization ...');
[Ti, inl] = laserCamLinearRobust(np.*[d;d;d],Pl,rt);
disp('done.');

if opt
    disp('Optimization ...');
    [T, r, ri] = optimizeLaserCamCalib(Ti, Tp(:,:,inl), Pl(inl));
    disp('done.');
end