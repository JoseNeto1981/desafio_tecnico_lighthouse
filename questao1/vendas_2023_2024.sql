 -- Quantidade de linhas + intervalo de datas
SELECT 
    COUNT(*) AS quantidade_linhas,
    MIN(sale_date) AS data_minima,
    MAX(sale_date) AS data_maxima,
    MIN(total) AS valor_minimo,
    MAX(total) AS valor_maximo,
    AVG(total) AS valor_medio
FROM LH_NAUTICALS.QUESTAO1.VENDAS_2023_2024;

-- Quantidade de colunas
desc table LH_NAUTICALS.QUESTAO1.VENDAS_2023_2024;
