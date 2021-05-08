// knots unique and multiplicity
      function knots_uniq_mult(p, knots) {
        var knots_unique = [];
        var multiplicity = [];
        var temp_mult = 1;
        var ni = Object.keys(knots).length;
        for (i = 1; i < ni; i++) {
          if (knots[i] > knots[i - 1]) {
            knots_unique.push(knots[i - 1]);
            multiplicity.push(temp_mult);
            temp_mult = 1;
          } else {
            temp_mult = temp_mult + 1;
          }
        }
        if (knots[i - 2] == knots[i - 1]) {
          knots_unique.push(knots[i - 1]);
          multiplicity.push(temp_mult);
        }
        return [knots_unique, multiplicity];
      }
	  
	        // knot span and sample vector
      function xi_vec(unique_knots, unique_knots_mult, n) {
        var xi = Array((unique_knots.length - 2) * n + 1);
        var s = Array(xi.length);
        var k = -1;
        var pos = 0.0;
        var step = 0.0;
        var start = 0.0;
        for (var j = 0; j < unique_knots.length - 1; j++) {
          step = (unique_knots[j + 1] - unique_knots[j]) / (n - 1);
          start = unique_knots[j];
          k = k + unique_knots_mult[j];
          for (var i = 0; i < n - 1; i++) {
            xi[pos] = start + (step * i);
            s[pos] = k;
            pos++;
          }
        }
        xi[pos] = unique_knots[j];
        s[pos] = k;
        return [xi, s];
      }
	  
	  // knots unique and multiplicity
      function knots_uniq_mult(p, knots) {
        var knots_unique = [];
        var multiplicity = [];
        var temp_mult = 1;
        var ni = Object.keys(knots).length;
        for (i = 1; i < ni; i++) {
          if (knots[i] > knots[i - 1]) {
            knots_unique.push(knots[i - 1]);
            multiplicity.push(temp_mult);
            temp_mult = 1;
          } else {
            temp_mult = temp_mult + 1;
          }
        }
        if (knots[i - 2] == knots[i - 1]) {
          knots_unique.push(knots[i - 1]);
          multiplicity.push(temp_mult);
        }
        return [knots_unique, multiplicity];
      }
	  
	  // knot vector from mult and unique
      function new_knots(unique_knots, multiplicity, p) {
        var knots = [];
        for (i = 0; i < unique_knots.length; i++) {
          for (m = 1; m <= multiplicity[i]; m++) {
            knots.push(unique_knots[i]);
          }
        }
        return knots;
      }
	  
	  // calculate b-spline by de boor formula
      function de_boor(xi, p, knots, points) {
        if (xi < knots[p - 1] || xi > knots[p]) {
          return 0.0;
        }
        for (k = 1; k <= p; k++) {
          for (j = 0; j <= p - k; j++) {
            var idx = p - j - 1;
            var alpha = (xi - knots[idx]) / (knots[idx + p - k + 1] - knots[idx]);
            points[j] = points[j + 1] * (1.0 - alpha) + points[j] * alpha;
          }
        }
        return points[0];
      }
	  
	  // get knot coordinate knot span Algorithm A2.1 from 'The NURBS BOOK' pg68 
      function knot_span(xi, p, knots, nR) {
        if (xi == knots[nR + 1]) {
          return nR;
        }
        min = p;
        max = nR + 1;
        s = Math.floor((min + max) / 2.0);
        while (xi < knots[s] || xi >= knots[s + 1]) {
          if (xi < knots[s]) {
            max = s;
          } else {
            min = s;
          }
          s = Math.floor((min + max) / 2.0);
        }
        return s;
      }
	  
	  // calculate NURBS base functions at xi
      function base_f_xi_w(xi, s, p, knots, nR, weights) {
        var R = Array(nR + 1).fill().map(() => Array(xi.length).fill(0.0));
        var temp_points = new Array(p + 1);
        var temp_knots, val, val_w;
        for (var i = 0; i < xi.length; i++) {
          temp_knots = knots.slice(s[i] - p + 1, s[i] + p + 1);
          temp_points = weights.slice(s[i] - p, s[i] + 1).reverse();
          val_w = de_boor(xi[i], p, temp_knots, temp_points);
          for (var j = 0; j <= nR; j++) {
            temp_points.fill(0.0);
            if (-j + s[i] >= 0 && -j + s[i] <= p) {
              temp_points[-j + s[i]] = 1.0;
              val = de_boor(xi[i], p, temp_knots, temp_points);
              R[j][i] = val * weights[j] / val_w;
            } else {
              R[j][i] = 0.0;
            }
          }
        }
        return R;
      }
	  
	  // get unique knots
      function unique_knots(value, index, self) {
        return self.indexOf(value) === index;
      }
	  // create 2D bernstein base
	  function create_2Dbase_bernstein(n_samples, p, dir) {
        var xi = linspace(-1.0, 1.0, n_samples[dir[0]]);
        var eta = linspace(-1.0, 1.0, n_samples[dir[1]]);
        var B_xi = bernstein_poly(xi, p[dir[0]]);
        var B_eta = bernstein_poly(eta, p[dir[1]]);
        var B = math.kron(B_eta, B_xi);
        return B;
      }
	  
	  
	  // linspace
      function linspace(start, end, n) {
        var vector = [];
        var pos = start;
        var step = (end - start) / (n - 1);
        for (var i = 0; i < n; i++) {
          vector.push(pos + (step * i));
        }
        return vector;
      }
	  
	  
	  // calculate NURBS spline
      function NURBS_spline(xi, p, knots, nR, points) {
        var s = knot_span(xi, p, knots, nR);
        var temp_knots = knots.slice(s - p + 1, s + p + 1);
        var xyw = new Array(3);
        var temp_weights = points[2].slice(s - p, s + 1).reverse();
        xyw[2] = de_boor(xi, s, p, temp_knots, temp_weights);
        for (i = 0; i <= 1; i++) {
          var temp_points = points[i].slice(s - p, s + 1).reverse();
          for (j = 0; j <= p; j++) {
            temp_points[j] = temp_points[j] * temp_weights[j];
          }
          xyw[i] = de_boor(xi, s, p, temp_knots, temp_points) / xyw[2];
        }
        return xyw;
      }
	  
	  
	  // calculate bernstein polynomials
      function bernstein_poly(x, p) {
        var B = new Array(x.length);
        var temp_1 = 0.0;
        var temp_0 = 0.0;
        var xi = new Array(x.length);
        var xi_compl = new Array(x.length);
        for (i = 0; i < x.length; i++) {
          B[i] = new Array(p + 1);
          B[i][0] = 1.0;
          xi[i] = (x[i] + 1.0) / 2.0;
          xi_compl[i] = 1.0 - xi[i]
        }
        for (j = 1; j <= p; j++) {
          for (i = 0; i < x.length; i++) {
            temp_0 = 0.0;
            for (k = 0; k < j; k++) {
              temp_1 = B[i][k];
              B[i][k] = temp_0 + xi_compl[i] * temp_1;
              temp_0 = xi[i] * temp_1;
            }
            B[i][j] = temp_0;
          }
        }
        return B;
      }
	  
	  
	  // get bezier knots and indizes
      function knots_bezier(p, knots_old) {
        var knots_unique = [];
        var multiplicity = [];
        var temp_mult = 1;
        var ni = Object.keys(knots_old).length;
        for (i = 1; i < ni; i++) {
          if (knots_old[i] > knots_old[i - 1]) {
            knots_unique.push(knots_old[i - 1]);
            multiplicity.push(temp_mult);
            temp_mult = 1;
          } else {
            temp_mult = temp_mult + 1;
          }
        }
        if (knots_old[i - 2] == knots_old[i - 1]) {
          knots_unique.push(knots_old[i - 1]);
          multiplicity.push(temp_mult);
        }
        ni = knots_unique.length;
        var bezier_ij = [
          [0, 0]
        ];
        for (i = 1; i < ni - 1; i++) {
          bezier_ij[i] = [bezier_ij[i - 1][1] + multiplicity[i], bezier_ij[i - 1][1] + p];
        }
        var knots_bezier = [];
        for (i = 0; i < ni; i++) {
          for (m = 1; m <= Math.max(multiplicity[i], p); m++) {
            knots_bezier.push(knots_unique[i]);
          }
        }
        return [knots_bezier, bezier_ij];
      }
	  
	  // subdivide knots and get bezier knots and indizes
      function knots_subd(p, knots_old) {
        var knots_unique = [];
        var multiplicity = [];
        var temp_mult = 1;
        var ni = Object.keys(knots_old).length;
        for (i = 1; i < ni; i++) {
          if (knots_old[i] > knots_old[i - 1]) {
            knots_unique.push(knots_old[i - 1]);
            multiplicity.push(temp_mult);
            knots_unique.push(0.5 * (knots_old[i - 1] + knots_old[i]));
            multiplicity.push(1);
            temp_mult = 1;
          } else {
            temp_mult = temp_mult + 1;
          }
        }
        if (knots_old[i - 2] == knots_old[i - 1]) {
          knots_unique.push(knots_old[i - 1]);
          multiplicity.push(temp_mult);
        }
        ni = knots_unique.length;
        var bezier_ij = [
          [0, 0]
        ];
        for (i = 1; i < ni - 1; i++) {
          bezier_ij[i] = [bezier_ij[i - 1][1] + multiplicity[i], bezier_ij[i - 1][1] + p];
        }
        var knots_subdiv = [];
        for (i = 0; i < ni; i++) {
          for (m = 1; m <= multiplicity[i]; m++) {
            knots_subdiv.push(knots_unique[i]);
          }
        }
        var knots_bezier = [];
        for (i = 0; i < ni; i++) {
          for (m = 1; m <= Math.max(multiplicity[i], p); m++) {
            knots_bezier.push(knots_unique[i]);
          }
        }
        return [knots_subdiv, knots_bezier, bezier_ij];
      }
	  
	  
	  // oslo algorithm
      function oslo_global(p, knots_old, knots_new) {
        var nR_old = knots_old.length - p - 2;
        var nR_new = knots_new.length - p - 2;
        var i_indx = new Array(nR_old);
        var i = 0;
        var x = 0.0;
        var w1 = 0.0;
        for (j = 0; j <= nR_new; j++) {
          i_indx[j] = i;
        }
        var M = Array.from(Array(nR_old + 1), () => Array.from(Array(nR_new + 1).fill(0.0)));
        for (j = 0; j <= nR_new; j++) {
          while ((i <= nR_old) && !((knots_old[i] <= knots_new[j]) && (knots_new[j] < knots_old[i + 1]))) {
            i = i + 1;
          }
          M[i][j] = 1.0;
          for (k = 1; k <= p; k++) {
            M[i - k][j] = 0.0;
          }
          for (k = 1; k <= p; k++) {
            x = knots_new[j + k];
            w2 = (knots_old[i + 1] - x) / (knots_old[i + 1] - knots_old[i + 1 - k]);
            M[i - k][j] = w2 * M[i - k + 1][j];
            for (a = 2; a <= k; a++) {
              w1 = w2;
              w2 = (knots_old[i + a] - x) / (knots_old[i + a] - knots_old[i - k + a]);
              M[i - k + a - 1][j] = (1.0 - w1) * M[i - k + a - 1][j] + w2 * M[i - k + a][j];
            }
            M[i][j] = (1.0 - w2) * M[i][j];
          }
        }
        return math.matrix(M, 'sparse');
      }