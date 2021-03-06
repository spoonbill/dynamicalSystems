function plotStep2D(obj, posteriorType)
    % plotStep2D(obj, posteriorType)
    %
    % INPUTS:
    % obj           - a dynamicalSystems object.
    % posteriorType - either 'filter' or 'smooth'
    %
    % DESCRIPTION:
    % Plot prediction and correction posteriors at each time step. Useful
    % demonstration of how kalman filter works. Note: coded assuming 2D
    % state space: if not will error.
    
    figure
    plot(obj.par.x0.mu(1), obj.par.x0.mu(2), 'b+');
    hold on;
    
    usePosterior = obj.infer.(posteriorType);
    mu      = usePosterior.mu;
    sigma   = usePosterior.sigma;
    
    m       = obj.par.x0.mu;
    P       = obj.par.x0.sigma;
    
    for tt = 1:obj.d.T
        % one step ahead
        m_minus         = obj.par.A * m;
        P_minus         = obj.par.A * P * obj.par.A' + obj.par.Q;
        [ppt1, ppt2] = plotGaussLevel(m_minus, P_minus, 'g', ':', tt>1);
        pause;
        
        % correct with next y value
        plot(obj.y(1,tt), obj.y(2,tt), 'r+');
        plotGaussLevel(mu(:,tt), sigma{tt}, 'b', ':');
        plot([m(1), mu(1,tt)], [m(2), mu(2,tt)], 'b-');
        pause;
        
        m = mu(:,tt);
        P = sigma{tt};
        
        % delete previous prediction points
        if (ishandle(ppt1)); delete(ppt1); end
        if (ishandle(ppt2)); delete(ppt2); end
    end
end


function [pt1, pt2] = plotGaussLevel(mu, sigma, col, style, doVar)
    % plot mean and level curve (1 sd) of Gaussian.
    % Optionally return the pointers of the mean and var lines.
    
    if nargin < 5 || isempty(doVar)
        doVar = true;
    end
    
    origHoldOn = ishold;
    hold on
    pt1 = plot(mu(1), mu(2), [col, '+']);
    
    
    if doVar
        lc = utils.plot.gaussian2DLevelCurve(1, mu, sigma, 100);
        pt2 = plot(lc(:,1), lc(:,2), [col, style]);
    else
        pt2 = [];
    end
    
    if ~origHoldOn 
        hold off;
    end
end