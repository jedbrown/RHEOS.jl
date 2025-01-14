struct Interface
          uϵ::Symbol
          uσ::Symbol
          from_ϵσ::Function
          to_ϵσ::Function
       end


function Base.getindex(d::RheoTimeData, i::Interface)
          return( NamedTuple{(i.uϵ, i.uσ),Tuple{Vector{RheoFloat},Vector{RheoFloat}}}( i.from_ϵσ(d.ϵ,d.σ) )   )
       end



function RheoTimeData(interface::Interface ; t::Vector{T3} = RheoFloat[], comment="Created from generic constructor", savelog = true, log = savelog ? RheoLogItem(comment) : nothing, kwargs...)  where {T1<:Real, T2<:Real, T3<:Real}

   if interface.uϵ in keys(kwargs)
      uϵ = convert(Vector{RheoFloat}, kwargs[interface.uϵ])
   else
      uϵ = RheoFloat[]
   end

   if interface.uσ in keys(kwargs)
      uσ = convert(Vector{RheoFloat}, kwargs[interface.uσ])
   else
      uσ = RheoFloat[]
   end

  typecheck = check_time_data_consistency(t,uϵ,uσ)
  RheoTimeData(convert(Vector{RheoFloat},σ), convert(Vector{RheoFloat},ϵ), convert(Vector{RheoFloat},t),
  log == nothing ? nothing : [ RheoLogItem(log.action,merge(log.info, (type=typecheck, interface = interface)))]     )

end


function importcsv(filepath::String, interface::Interface; t_col::IntOrNone = nothing, delimiter = ',', comment = "Imported from csv file", savelog = true, kwargs...)
   cols = kwargs.data   # should contain column numbers for the strain and stress equivalent data
   uϵ_col_sym = Symbol(string(interface.uϵ) * "_col")
   uσ_col_sym = Symbol(string(interface.uσ) * "_col")

   if uϵ_col_sym in keys(cols)
      uϵ_col = cols[uϵ_col_sym]
   else
      uϵ_col = nothing
   end

   if uσ_col_sym in keys(cols)
      uσ_col = cols[uσ_col_sym]
   else
      uσ_col = nothing
   end

   data = importcsv(filepath, t_col = t_col, σ_col = uσ_col, ϵ_col = uϵ_col, delimiter = delimiter, comment = comment, savelog = savelog)

   # need to make sure that missing columns are properly transfered.
   ϵ,σ = interface.to_ϵσ(data.ϵ, data.σ)

     log = if savelog
             info = (comment=comment, folder=pwd(), stats=(t_min=data[1,t_col],t_max=data[end,t_col], n_sample=size(data[:,t_col])))
             kwds = NamedTuple{(:t_col, uϵ_col_sym, uσ_col_sym),Tuple{IntOrNone,IntOrNone,IntOrNone}}( (t_col, uϵ_col, uσ_col) )
             RheoLogItem( (type=:source, funct=:importcsv, params=(filepath=filepath, interface=interface), keywords=kwds), info )
           else
             nothing
           end

   return RheoTimeData(σ, ϵ, t, [log])

end



function AFM(R::float)
   Interface(:d, :f, (ϵ,σ)-->(d = (R*(3./4.)^(2./3)) * ϵ^(2./3), f = R^2 * σ ), (d,f)-->(ϵ = 4./(3.*R^1.5) * d^1.5, σ = f/R^2) )
end

function Tweezers(R::float)
   Interface(:d, :f, (ϵ,σ)-->(d = (R) * ϵ, f = R^2 * σ ), (d,f)-->(ϵ = 1.*(d/R)^1.5, σ = f/R^2) )
end
