function deferred_acceptance(apply_prefs::Array{Int64}, accept_prefs::Array{Int64}, caps=ones(Int64, length(accept_prefs[1, :])))
    num_of_apply = length(accept_prefs[:,1])-1
    num_of_accept = length(accept_prefs[1,:])
    
    ranking = zeros(Int64, num_of_apply+1, num_of_accept)
    
    da = zeros(Int64, num_of_apply+1, num_of_accept+1)
    
    num_of_da = zeros(Int64, num_of_accept)
    
    for i in 1:num_of_apply+1
        if i == num_of_apply+1
            search = 0
        else
            search = i
        end
        
        for j in 1:num_of_accept
            ranking[i, j] = findfirst(accept_prefs[:,j], search)
        end
    end
    
    rem = [1 for i in 1:length(apply_prefs[1,:])]
    depth = ones(Int64, length(accept_prefs[:,1])-1)
    
    b=1
    while true
        apply = findfirst(rem, 1)
        if apply == 0
            break
        end
        
        d = depth[apply]
        if d >= num_of_apply
            rem[apply] = 0
        else
            
            applied = apply_prefs[d, apply]

            if applied == 0
                rem[apply] = 0
            else
                my_rank = ranking[apply, applied]
                if num_of_da[applied] < caps[applied]
                    if my_rank < ranking[end, applied]
                        da[apply, applied] = 1
                        num_of_da[applied] += 1
                        rem[apply] = 0
                    else  
                        depth[apply] += 1
                    end
                else 
                    list_of_da = findn(da[:, applied])

                    da_rank = Array(Int64, length(list_of_da))
                    

                    for i in 1:length(list_of_da)
                        da_rank[i] = ranking[list_of_da[i], applied]
                    end

                    
                    worst_st_rank = maximum(da_rank)
                    worst_st = list_of_da[findfirst(da_rank, worst_st_rank)]                 

                    if my_rank < worst_st_rank
                        rem[apply] = 0
                        da[apply, applied] = 1
                        da[worst_st, applied] = 0
                        rem[worst_st] = 1
                        depth[worst_st] += 1
                    else
                        depth[apply] += 1
                    end

                end
            end
        end
    end
    
    accept_matched = Array(Int64, 0)
    apply_matched = zeros(Int64, num_of_apply)
    
    for i in 1:num_of_accept
        das = findn(da[:, i])
        append!(das, zeros(Int64, caps[i] - length(das)))
        append!(accept_matched, das)
        for d in das
            if d != 0
                apply_matched[d] = i
            end
        end
    
    end
    
    indptr = Array(Int64, num_of_accept+1)
    indptr[1] = 1
    for i in 1:num_of_accept
        indptr[i+1] = indptr[i] + caps[i]
    end
    return apply_matched, accept_matched, indptr
end