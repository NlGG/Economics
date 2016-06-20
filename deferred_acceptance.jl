function deferred_acceptance(apply_prefs::Array{Int64, 2}, accept_prefs::Array{Int64, 2}) 
    da = zeros(Int64, length(accept_prefs[1,:]))
    rem = [i for i in 1:length(apply_prefs[1,:])]
    depth = ones(Int64, length(accept_prefs[:,1])-1)
    
    while length(rem) != 0
        apply = rem[end]
        d = depth[apply]
        if d == length(accept_prefs[:,1])
            pop!(rem)
        end
        applied = apply_prefs[d, apply]
        if applied == 0
            pop!(rem)
        else
            if find(accept_prefs[:,applied] .== apply)[1] < find(accept_prefs[:,applied] .== da[applied])[1]
                pop!(rem)
                if da[applied] != 0
                    push!(rem, da[applied])
                    depth[da[applied]] += 1
                end
                da[applied] = apply
            else
                depth[apply] += 1
            end
        end
    end

    accept_matched = da
    apply_matched = zeros(Int64, length(apply_prefs[1,:]))
    
    for i in 1:length(accept_matched)
        if accept_matched[i] != 0
            apply_matched[accept_matched[i]] = i
        end
    end
    return apply_matched, accept_matched
end