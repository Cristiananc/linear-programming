#Programação Linear e Inteira

#Cristiana Couto
#Solucionando o jogo FlowFree através de programação linear inteira

using JuMP, GLPK

model = Model(GLPK.Optimizer)
nodesInput = [1, 3, 5, 6, 7, 8, 9, 19, 20, 21, 29, 31];
nodesColors = [6, 5, 2, 1, 4, 6, 3, 5, 4, 3, 2, 1];

function flowFree(model, n, nodesInput, c, nodesColors)
    
    @variable(model, 1 >= N[1:n*n, 1:4, 1:c] >= 0, Int)
    @variable(model, 1 >= C[1:n*n, 1:c] >= 0, Int)
    
    #Cada nó só tem no maxímo 2 arestas saindo dele e no mínimo 1
    #Nós terminais só possuem uma aresta saindo dele
    for i in 1:n*n
        if i in nodesInput
            @constraint(model, sum(N[i,1:4, 1:c]) == 1)
        else
            @constraint(model, 1 <= sum(N[i,1:4, 1:c]) <= 2)
        end
    end
    
    #Restrições de cores
    for i in 1:n*n
        @constraint(model, sum(C[i, 1:c]) == 1)
        if i ∉ nodesInput
            for j in 1:c
                @constraint(model, C[i,j] == sum(N[i,1:4,j])*0.5)
            end
        else
            for k in 1:c
                @constraint(model, C[i,k] == sum(N[i,1:4,k]))
            end
        end
    end
    
    #Cada aresta só possui uma cor e soma zero se ela não existe
    for i in 1:n*n
        for j in 1:4
           @constraint(model, sum(N[i,j, 1:c]) <= 1)
        end
    end

    #Cores do input nos nós terminais
    for j in 1:size(nodesInput)[1]
        @constraint(model, sum(N[nodesInput[j], i, nodesColors[j]] for i in 1:4) == 1)
    end    
    
    
    #Os nós da borda não possuem algumas arestas 1= esquerda, 2= p/ cima, 3= direita, 4 = p/ baixo
    #Começando pelos nós que não têm aresta esquerda
    for i in 0:n-1
        @constraint(model, sum(N[i*n + 1,1, 1:c]) == 0)
    end

    #Nós que não têm aresta p/ baixo
    for i in n*(n-1) + 1:n*n
        @constraint(model, sum(N[i, 4, 1:c]) == 0)
    end
    
    #Nós que não têm aresta p/ cima e nós que não têm aresta p/ direita
    for i in 1:n
        @constraint(model, sum(N[i, 2, 1:n]) == 0)
        @constraint(model, sum(N[i*n, 3, 1:n]) == 0)
    end
    
    #A aresta (u,v) tem a mesma cor que a aresta (v,u)
    #Os vizinhos na horizontal e vertical que compartilham arestas precisam 
    #ter as mesmas cores (começamos pelo subtabuleiro que possui todos os vizinhos)
    for i in n+2:n*n - (n+1)
        @constraint(model, N[i, 1, 1:c] .== N[i - 1, 3, 1:c])
        @constraint(model, N[i, 2, 1:c] .== N[i - 6, 4, 1:c])
        @constraint(model, N[i, 3, 1:c] .== N[i + 1, 1, 1:c])
        @constraint(model, N[i, 4, 1:c] .== N[i + 6, 2, 1:c])
    end

    #Última linha (nós que são não canto)
    for i in (n-1)*n + 2:n*n -1
        @constraint(model, N[i, 1, 1:c] .== N[i - 1, 3, 1:c])
        @constraint(model, N[i, 2, 1:c] .== N[i - 6, 4, 1:c])
        @constraint(model, N[i, 3, 1:c] .== N[i + 1, 1, 1:c])
    end

    #Primeira linha e última coluna (nós que são não canto)
    for i in 2:n-1
        @constraint(model, N[i, 1, 1:c] .== N[i - 1, 3, 1:c])
        @constraint(model, N[i, 3, 1:c] .== N[i + 1, 1, 1:c])
        @constraint(model, N[i, 4, 1:c] .== N[i + 6, 2, 1:c])
        
        @constraint(model, N[i*n, 1, 1:c] .== N[i*n - 1, 3, 1:c])
        @constraint(model, N[i*n, 2, 1:c] .== N[i*n - 6, 4, 1:c])
        @constraint(model, N[i*n, 4, 1:c] .== N[i*n + 6, 2, 1:c])
    end

    #Primeira coluna
    for i in 1:n-2
        @constraint(model, N[i*n + 1, 2, 1:c] .== N[i*n - 5, 4, 1:c])
        @constraint(model, N[i*n + 1, 3, 1:c] .== N[i*n + 2, 1, 1:c])
        @constraint(model, N[i*n + 1, 4, 1:c] .== N[i*n + 7, 2, 1:c])
    end
    
    #Cantos
    #Casa [1,1] do tabuleiro
    @constraint(model, N[1, 3, 1:c] .== N[2, 1, 1:c])
    @constraint(model, N[1, 4, 1:c] .== N[n+1, 2, 1:c])

    #Casa [1,n]
    @constraint(model, N[n, 1, 1:c] .== N[n-1, 3, 1:c])
    @constraint(model, N[n, 4, 1:c] .== N[2*n, 2, 1:c])

    #Casa [n,1]
    @constraint(model, N[n*(n-1) + 1, 2, 1:c] .== N[n*(n-1) + 1 - n, 4, 1:c])
    @constraint(model, N[n*(n-1) + 1, 3, 1:c] .== N[n*(n-1) + 2, 1, 1:c])

    #Casa [n,n]
    @constraint(model, N[n*n, 1, 1:c] .== N[n*n - 1, 3, 1:c])
    @constraint(model, N[n*n, 2, 1:c] .== N[n*(n - 1), 4, 1:c])
    
    # Chamada do Solver
    optimize!(model)
    
    return value.(N), value.(C)
end

function tabuleiro(c, F)
    Tabuleiro = zeros(c, c)
    for i in 1:(size(F)[1])
        if F[i][1] % c == 0
            Tabuleiro[trunc(Int, F[i][1]/c), c] = F[i][3]
        else
            Tabuleiro[trunc(Int, F[i][1]/c + 1), trunc(Int, F[i][1] % c)] = F[i][3]
        end
    end
    return Tabuleiro
end

#Exemplo
M, C = flowFree(model, 6, nodesInput, 6, nodesColors);
F = findall(x->x==1, value.(M))
tabuleiro(6,F)

