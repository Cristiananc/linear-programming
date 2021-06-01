#= O algoritmo branch and bound é utilizado para lidar com problemas de programação linear inteira.

    Entradas: A, b, restricoes, objetivo (veja comentários para a função SEF)
    - lower_bound: Variável opcional que inicia com o valor default de -inf caso não haja um input. Ao longo 
do algortitmo atualizamos o lower_bound como sendo o menor valor de z tal que todos os elementos do
vetor solução sejam inteiros;
    - sol_integer: Variável opcional cujo valor default é um array vazio. Durante as chamadas recursivas 
do branch and bound, sol_integer é o vetor de solução inteira que acompanha o lower_bound;

    Saídas:
    - lower_bound: Solução do problema de programação linear inteira;
    - sol_integer: Vetor de elementos de inteiros.
    - subproblem: Inteiro com o total de subproblemas do problema.
=#
function branch_and_bound(A, b, restricoes, variaveis, objetivo, lower_bound::Float64 = -Inf, sol_integer::Any = [])
    
    #Chamamos o simplex para os valores do problema, fazendo o que se chama de relaxação das restrições
    #na qual a restrição de variável inteira é ignorada
    simplex_bb = simplex(A,b,restricoes,variaveis,objetivo)
    
    #Prosseguimos o algoritmo caso o simplex encontre uma solução. Se o problema não possui solução para valores
    #contínuos, consequentemente não há solução inteira.
    if typeof(simplex_bb) != Nothing
        z_subproblem, sol_subproblem = simplex_bb
        index = 0
        stop = 1

        #Encontra o primeiro index do vetor de soluçoes obtido pelo simplex que não é inteiro
        while stop == 1
            index+= 1
            if floor(sol_subproblem[index]) - sol_subproblem[index] != 0.0
                stop = 0
            #Caso em que a solução é um vetor de inteiros
            elseif index == length(sol_subproblem)
                stop = 0
                index = 0
                #Se o z encontrado for > que o lower_bound atual atualizamos o valor do lower_bound e da solução
                #inteira atual
                if z_subproblem > lower_bound
                    lower_bound = z_subproblem
                    sol_integer = sol_subproblem
                    
                    println("Solução inteira: ", sol_integer," e z = ", lower_bound)
                end
            end
        end
        
        maxminSim = 0 #chave para saber se o problema foi passando especificando o caso em que é maximo ou minimo 

        #Loop que chama a função branch and bound recursivamente
        while index != 0 && z_subproblem > lower_bound
            
            #Variável escolhida para os ramos com os subproblemas 
            x = sol_subproblem[index]

            # Precisamos adicionar uma nova linha na matriz A referente a restrição <= ou =>
            nova_linha = zeros(1, size(A)[2])
            nova_linha[index] = 1
            A = [A; nova_linha]
            up = floor(x) + 1
            down = floor(x)
            
            #Atualizando as restrições dos subproblemas
            if restricoes[end] == "max" || restricoes[end] == "min" 
                salvar = restricoes[end]
                restricoesNewaux = restricoes[1, 1:end .!=end]
                restricoesNew = reshape(restricoesNewaux,1,size(restricoesNewaux,1))
                maxminSim = 1
                salvar = restricoes[1,end]
            else 
                restricoesNew = restricoes
            end
            
            restricoesUp = [restricoesNew ">="]
            restricoesDown = [restricoesNew "<="]
            
            if maxminSim == 1
                restricoesUp = [restricoesUp salvar]
                restricoesDown = [restricoesDown salvar]
            end
            
            #Atualizando os vetores b dos subproblemas da esquerda e da direita
            bUp = [b up]
            bDown = [b down]
            
            #Chamamos o algoritmo branch and bound para o ramo esquerdo
            println("RAMO 1:")
            z_integer1, solution1 = branch_and_bound(A, bUp, restricoesUp, variaveis, objetivo, lower_bound, sol_integer)
            println(z_integer1)
                        
            #Chamamos o algoritmo branch and bound para o ramo direito1
            #Aqui colocamos como entrada o z_integer1 e a solution1 que são os valores ótimos encontrados
            #no ramo à esquerda. Note que o valor do lower_bound serve como regra para continuar um ramo 
            #ou "podá-lo". 
            println("RAMO 2:")
            z_integer2, solution2 = branch_and_bound(A, bDown, restricoesDown, variaveis, objetivo, z_integer1, solution1)
            println(z_integer2)
            
            #Compara os valores ótimos obtidos nos dois lados dos ramos e seta o lower_bound como o maior
            #entre os dois. Além de atualizar o vetor de solução.
            if z_integer1 > z_integer2
                lower_bound = z_integer1
                sol_integer = solution1
            else
                lower_bound = z_integer2
                sol_integer = solution2
            end
            index = 0
        end
    end
    return lower_bound, sol_integer
end
