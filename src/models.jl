#!/usr/bin/env julia

######################
#~ mittleff wrapper ~#
######################

"""
    mittleff(α::Float64[, β::Float64], x::Array{Float64,1})

Convience wrapper around MittagLeffler.mittleff for array arguments. X array is
limited to float type in accordance with the requirements of RHEOS.
"""
function mittleff(α::Float64, xList::Array{Float64,1})::Array{Float64,1}
    # call mittagleffler within an array comprehension
    y = [MittagLeffler.mittleff(α, x) for x in xList]
end

function mittleff(α::Float64, β::Float64, xList::Array{Float64,1})::Array{Float64,1}
    # call mittagleffler within an array comprehension
    y = [MittagLeffler.mittleff(α, β, x) for x in xList]
end

#########################
#~ G Relaxation Moduli ~#
#########################

"""
    G_SLS(t::Array{Float64,1}, params::Array{Float64,1})

Standard Linear Solid / Zener Model with 1 time scale. Parameters by index order:
Gₑ, G₁, τ₁
"""
function G_SLS(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    G = params[1] + params[2]*exp.(-t/params[3])
end

"""
    G_SLS2(t::Array{Float64,1}, params::Array{Float64,1})

Standard Linear Solid / Zener Model with 2 time scales, also known as Wiechert.
model. Parameters by index order: Gₑ, G₁, τ₁, G₂, τ₂
"""
function G_SLS2(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    G = params[1] + params[2]*exp.(-t/params[3]) + params[4]*exp.(-t/params[5])
end

"""
    G_burgers(t::Array{Float64,1}, params::Array{Float64,1})

Burgers model. 2 time scales, relaxes to 0. Parameters by index order: G₁, τ₁, G₂, τ₂
"""
function G_burgers(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    G = params[1]*exp.(-t/params[2]) + params[3]*exp.(-t/params[4])
end

"""
    G_springpot(t::Array{Float64,1}, params::Array{Float64,1})

Single Spring-pot model. Parameters by index order: cᵦ, ν
"""
function G_springpot(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    G = params[1]*t.^(-params[2])/gamma(1-params[2])
end

"""
    G_fractKV(t::Array{Float64,1}, params::Array{Float64,1})

Fractional Kelvin-Voigt model as defined by Mainardi & Spada (2011) parameters
by index order: μ, cᵦ, ν
"""
function G_fractKV(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    G = 2*params[1]*(1+(params[2]*t.^(-params[3]))/gamma(1-params[3]))
end

"""
    G_fractmaxwell(t::Array{Float64,1}, params::Array{Float64,1})

Fractional Maxwell model as defined by Mainardi & Spada (2011) parameters by
index order: μ, τ, ν
"""
function G_fractmaxwell(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    G = 2*params[1]*mittleff(params[3], -((t/params[2]).^params[3]))
end

"""
    G_fractzener(t::Array{Float64,1}, params::Array{Float64,1})

Fraction Zener model as defined by Mainardi & Spada (2011) parameters by index
order: μ*, r, τ, ν
"""
function G_fractzener(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    G = 2*params[1]*(1 + params[2]*mittleff(params[4], -((t/params[3]).^params[4])))
end

"""
    G_fractspecial(t::Array{Float64,1}, params::Array{Float64,1})

Special fractional model defined by A. Bonfanti (2017) defined as a 1 spring in
parallel with a (spring-pot and dash-pot in series) parameters by index order:
K, Cᵦ, β, η
"""
function G_fractspecial(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    G = params[1] + params[2]*(t.^(-params[3])).*mittleff(1-params[3],1-params[3],-params[2]*(t.^(1-params[3]))/params[4])
end

####################
#~ J Creep Moduli ~#
####################

"""
    J_SLS(t::Array{Float64,1}, params::Array{Float64,1})

Standard Linear Solid / Zener Model with 1 time scale parameters by index order:
Jₑ, J₁, τ₁
"""
function J_SLS(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    J = params[1] - params[2]*exp.(-t/params[3])
end

"""
    J_SLS2(t::Array{Float64,1}, params::Array{Float64,1})

Standard Linear Solid / Zener Model with 2 time scales, also known as Wiechert
model parameters by index order: Jₑ, J₁, τ₁, J₂, τ₂
"""
function J_SLS2(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    J = params[1] - params[2]*exp.(-t/params[3]) - params[4]*exp.(-t/params[5])
end

"""
    J_burgers(t::Array{Float64,1}, params::Array{Float64,1})

Burgers model. Parameters by index order: Jₐ, Jᵦ, J₁, τ₁
"""
function J_burgers(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    J = params[1] + params[2]*t - params[3]*exp.(-t/params[4])
end

"""
    J_springpot(t::Array{Float64,1}, params::Array{Float64,1})

Single Spring-pot model parameters by index order: Cᵦ, β
"""
function J_springpot(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    J = (t.^params[2])/(params[1]*gamma(1+params[2]))
end

"""
    J_fractKV(t::Array{Float64,1}, params::Array{Float64,1})

Fractional Kelvin-Voigt model as defined by Mainardi & Spada (2011) parameters
by index order: μ, ν, τ
"""
function J_fractKV(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    J = (1-mittleff(params[2], -((t/params[3]).^params[2])))/(2*params[1])
end

"""
    J_fractmaxwell(t::Array{Float64,1}, params::Array{Float64,1})

Fractional Maxwell model as defined by Mainardi & Spada (2011) parameters by
index order: μ, ν, τ
"""
function J_fractmaxwell(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    J = (1 + ((t/params[3]).^params[2])/gamma(1+params[2]))/(2*params[1])
end

"""
    J_fractzener(t::Array{Float64,1}, params::Array{Float64,1})

Fraction Zener model as defined by Mainardi & Spada (2011) parameters by index
order: μ₁, μ₂, ν, τ₂
"""
function J_fractzener(t::Array{Float64,1}, params::Array{Float64,1})::Array{Float64,1}

    J = (1/params[1] + (1-mittleff(params[3], -(t/params[4]).^params[3]))/params[2])/2
end

###########################
#~ Model Function Return ~#
###########################

"""
    moduli(model::String, testType::String)

Get moduli function for requested viscoelastic model and test type (either
"strlx" for stress relaxation or "creep" for creep).

The following models are built in to RHEOS:

- `SLS`: Standard Linear Solid
- `SLS2`: 2 time scale Standard Linear Solid
- `burgers`: Burgers model
- `springpot`: Single Spring-Pot
- `fractKV`: Fractional Kelvin-Voigt model
- `fractmaxwell`: Fractional Maxwell model
- `fractzener`: Fractional Zener model
- `fractspecial`: *STRLX ONLY* - Fractional model defined by A. Bonfanti, 2017. *GET REF*

Additional models can be added at any time by the user by defining the model as
a function in "RHEOS/src/models.jl" and appending it the appropriate dictionary
within the `moduli` function which is in that same file.
"""
function moduli(model::String, test_type::String)::Function

    creepmoduli = Dict( "SLS"=>J_SLS,
                        "SLS2"=>J_SLS2,
                        "burgers"=>J_burgers,
                        "springpot"=>J_springpot,
                        "fractKV"=>J_fractKV,
                        "fractmaxwell"=>J_fractmaxwell,
                        "fractzener"=>J_fractzener)

    relaxmoduli = Dict( "SLS"=>G_SLS,
                        "SLS2"=>G_SLS2,
                        "burgers"=>G_burgers,
                        "springpot"=>G_springpot,
                        "fractKV"=>G_fractKV,
                        "fractmaxwell"=>G_fractmaxwell,
                        "fractzener"=>G_fractzener,
                        "fractspecial"=>G_fractspecial)

    if test_type=="creep"
        return creepmoduli[model]
    elseif test_type=="strlx"
        return relaxmoduli[model]
    end
end
