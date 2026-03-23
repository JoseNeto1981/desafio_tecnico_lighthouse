-- Ticket médio e a diversidade de categorias por clientes

WITH produtos_limpos AS (
    SELECT
        CODE AS PRODUCT_ID,
        NAME AS PRODUCT_NAME,
        CASE
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ANCORAGEM',
                'ANCORAJEN',
                'ENCORAGEM',
                'ANCORAGUEM',
                'ANCORAJM',
                'ANCORAGEM',
                'ANCORAJEM',
                'ENCORAGI',
                'A N C O R A G E M',
                'ANCORAJEM',
                'ANCORAGEN'
            ) THEN 'ANCORAGEM'

            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'PROPULSAO',
                'PROPULSÃO',
                'PROPULÇÃO',
                'PROPULÇAO',
                'PROPULSAM',
                'PROP',
                'PROPUÇÃO',
                'P R O P U L S Ã O',
                'PROPUCAO',
                'PROPULSSÃO'
            ) THEN 'PROPULSAO'

            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ELETRONICOS',
                'ELETRÔNICOS',
                'ELETRÔNICOS',
                'ELETRUNICOS',
                'ELETRONICOZ',
                'ELETRONISCOS',
                'ELETRÔNICO',
                'ELETRÔNICO',
                'ELETRONICOS',
                'E L E T R Ô N I C O S'
            ) THEN 'ELETRONICOS'

            ELSE UPPER(TRIM(ACTUAL_CATEGORY))
        END AS CATEGORY_LIMPA
    FROM LH_NAUTICALS.QUESTAO2.PRODUTOS_RAW
),

vendas_processadas AS (
    SELECT
        ID_CLIENT,
        TRY_TO_NUMBER(ID_PRODUCT) AS ID_PRODUCT,
        TRY_TO_NUMBER(TOTAL, 38, 2) AS TOTAL
    FROM LH_NAUTICALS.QUESTAO1.VENDAS_2023_2024
    WHERE TRY_TO_NUMBER(ID_PRODUCT) IS NOT NULL
      AND TRY_TO_NUMBER(TOTAL, 38, 2) IS NOT NULL
)

SELECT 
    v.ID_CLIENT,
    ROUND(AVG(v.TOTAL), 2) AS ticket_medio,
    COUNT(DISTINCT p.CATEGORY_LIMPA) AS diversidade_categorias
FROM vendas_processadas v
JOIN produtos_limpos p ON v.ID_PRODUCT = p.PRODUCT_ID
GROUP BY v.ID_CLIENT
ORDER BY v.ID_CLIENT;

-- Categorias mais consumidas e total de itens comprados

WITH produtos_limpos AS (
    SELECT
        CODE AS PRODUCT_ID,
        NAME AS PRODUCT_NAME,
        CASE
            -- ANCORAGEM
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ANCORAGEM',
                'ANCORAJEN',
                'ENCORAGEM',
                'ANCORAGUEM',
                'ANCORAJM',
                'ANCORAGEM',
                'ANCORAJEM',
                'ENCORAGI',
                'A N C O R A G E M',
                'ANCORAJEM',
                'ANCORAGEN'
            ) THEN 'ANCORAGEM'

            -- PROPULSAO
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'PROPULSAO',
                'PROPULSÃO',
                'PROPULÇÃO',
                'PROPULÇAO',
                'PROPULSAM',
                'PROP',
                'PROPUÇÃO',
                'P R O P U L S Ã O',
                'PROPUCAO',
                'PROPULSSÃO'
            ) THEN 'PROPULSAO'

            -- ELETRONICOS
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ELETRONICOS',
                'ELETRÔNICOS',
                'ELETRÔNICOS',
                'ELETRUNICOS',
                'ELETRONICOZ',
                'ELETRONISCOS',
                'ELETRÔNICO',
                'ELETRÔNICO',
                'ELETRONICOS',
                'E L E T R Ô N I C O S'
            ) THEN 'ELETRONICOS'

            ELSE UPPER(TRIM(ACTUAL_CATEGORY))
        END AS CATEGORY_LIMPA
    FROM LH_NAUTICALS.QUESTAO2.PRODUTOS_RAW
),

base_vendas AS (
    SELECT
        v.ID,
        v.ID_CLIENT,
        TRY_TO_NUMBER(v.ID_PRODUCT) AS ID_PRODUCT,
        TRY_TO_NUMBER(v.QTD) AS QTD,
        TRY_TO_NUMBER(v.TOTAL, 38, 2) AS TOTAL,
        p.CATEGORY_LIMPA
    FROM LH_NAUTICALS.QUESTAO4.VENDAS_REAL v
    INNER JOIN produtos_limpos p
        ON TRY_TO_NUMBER(v.ID_PRODUCT) = p.PRODUCT_ID
    WHERE TRY_TO_NUMBER(v.ID_PRODUCT) IS NOT NULL
      AND TRY_TO_NUMBER(v.QTD) IS NOT NULL
      AND TRY_TO_NUMBER(v.TOTAL, 38, 2) IS NOT NULL
),

metricas_cliente AS (
    SELECT
        ID_CLIENT,
        SUM(TOTAL) AS faturamento_total,
        COUNT(DISTINCT ID) AS frequencia,
        ROUND(SUM(TOTAL) / COUNT(DISTINCT ID), 2) AS ticket_medio,
        COUNT(DISTINCT CATEGORY_LIMPA) AS diversidade_categorias
    FROM base_vendas
    GROUP BY ID_CLIENT
),

clientes_elite AS (
    SELECT
        ID_CLIENT,
        faturamento_total,
        frequencia,
        ticket_medio,
        diversidade_categorias
    FROM metricas_cliente
    WHERE diversidade_categorias >= 3
),

top_10_clientes AS (
    SELECT
        ID_CLIENT,
        faturamento_total,
        frequencia,
        ticket_medio,
        diversidade_categorias
    FROM clientes_elite
    ORDER BY ticket_medio DESC, ID_CLIENT ASC
    LIMIT 10
),

ranking_categorias_top10 AS (
    SELECT
        b.CATEGORY_LIMPA,
        SUM(b.QTD) AS total_itens_comprados
    FROM base_vendas b
    INNER JOIN top_10_clientes t
        ON b.ID_CLIENT = t.ID_CLIENT
    GROUP BY b.CATEGORY_LIMPA
)

SELECT
    CATEGORY_LIMPA AS categoria_mais_consumida,
    total_itens_comprados
FROM ranking_categorias_top10
ORDER BY total_itens_comprados DESC, CATEGORY_LIMPA ASC
LIMIT 3;

-- Os 10 Clientes mais "Fiéis"
WITH produtos_limpos AS (
    SELECT
        CODE AS PRODUCT_ID,
        NAME AS PRODUCT_NAME,
        CASE
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ANCORAGEM',
                'ANCORAJEN',
                'ENCORAGEM',
                'ANCORAGUEM',
                'ANCORAJM',
                'ANCORAGEM',
                'ANCORAJEM',
                'ENCORAGI',
                'A N C O R A G E M',
                'ANCORAJEM',
                'ANCORAGEN'
            ) THEN 'ANCORAGEM'

            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'PROPULSAO',
                'PROPULSÃO',
                'PROPULÇÃO',
                'PROPULÇAO',
                'PROPULSAM',
                'PROP',
                'PROPUÇÃO',
                'P R O P U L S Ã O',
                'PROPUCAO',
                'PROPULSSÃO'
            ) THEN 'PROPULSAO'

            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ELETRONICOS',
                'ELETRÔNICOS',
                'ELETRÔNICOS',
                'ELETRUNICOS',
                'ELETRONICOZ',
                'ELETRONISCOS',
                'ELETRÔNICO',
                'ELETRÔNICO',
                'ELETRONICOS',
                'E L E T R Ô N I C O S'
            ) THEN 'ELETRONICOS'

            ELSE UPPER(TRIM(ACTUAL_CATEGORY))
        END AS CATEGORY_LIMPA
    FROM LH_NAUTICALS.QUESTAO2.PRODUTOS_RAW
),

base_vendas AS (
    SELECT
        v.ID,
        v.ID_CLIENT,
        TRY_TO_NUMBER(v.ID_PRODUCT) AS ID_PRODUCT,
        TRY_TO_NUMBER(v.QTD) AS QTD,
        TRY_TO_NUMBER(v.TOTAL, 38, 2) AS TOTAL,
        p.CATEGORY_LIMPA
    FROM LH_NAUTICALS.QUESTAO4.VENDAS_REAL v
    INNER JOIN produtos_limpos p
        ON TRY_TO_NUMBER(v.ID_PRODUCT) = p.PRODUCT_ID
    WHERE TRY_TO_NUMBER(v.ID_PRODUCT) IS NOT NULL
      AND TRY_TO_NUMBER(v.QTD) IS NOT NULL
      AND TRY_TO_NUMBER(v.TOTAL, 38, 2) IS NOT NULL
),

metricas_cliente AS (
    SELECT
        ID_CLIENT,
        SUM(TOTAL) AS faturamento_total,
        COUNT(DISTINCT ID) AS frequencia,
        ROUND(SUM(TOTAL) / COUNT(DISTINCT ID), 2) AS ticket_medio,
        COUNT(DISTINCT CATEGORY_LIMPA) AS diversidade_categorias
    FROM base_vendas
    GROUP BY ID_CLIENT
)

SELECT
    ID_CLIENT,
    faturamento_total,
    frequencia,
    ticket_medio,
    diversidade_categorias
FROM metricas_cliente
WHERE diversidade_categorias >= 3
ORDER BY ticket_medio DESC, ID_CLIENT ASC
LIMIT 10;

-- Categoria mais vendida entre os 10 clientes mais ativos
WITH produtos_limpos AS (
    SELECT
        CODE AS PRODUCT_ID,
        NAME AS PRODUCT_NAME,
        CASE
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ANCORAGEM', 'ANCORAJEN', 'ENCORAGEM', 'ANCORAGUEM', 'ANCORAJM',
                'ANCORAGEM', 'ANCORAJEM', 'ENCORAGI', 'A N C O R A G E M', 'ANCORAJEM',
                'ANCORAGEN'
            ) THEN 'ANCORAGEM'
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'PROPULSAO', 'PROPULSÃO', 'PROPULÇÃO', 'PROPULÇAO', 'PROPULSAM',
                'PROP', 'PROPUÇÃO', 'P R O P U L S Ã O', 'PROPUCAO',
                'PROPULSSÃO'
            ) THEN 'PROPULSAO'
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ELETRONICOS', 'ELETRÔNICOS', 'ELETRÔNICOS', 'ELETRUNICOS',
                'ELETRONICOZ', 'ELETRONISCOS', 'ELETRÔNICO', 'ELETRÔNICO',
                'ELETRONICOS', 'E L E T R Ô N I C O S'
            ) THEN 'ELETRONICOS'
            ELSE UPPER(TRIM(ACTUAL_CATEGORY))
        END AS CATEGORY_LIMPA
    FROM LH_NAUTICALS.QUESTAO2.PRODUTOS_RAW
),

top_10_clientes AS (
    SELECT 47 AS ID_CLIENT
    UNION ALL SELECT 9
    UNION ALL SELECT 42
    UNION ALL SELECT 36
    UNION ALL SELECT 28
    UNION ALL SELECT 46
    UNION ALL SELECT 26
    UNION ALL SELECT 48
    UNION ALL SELECT 2
    UNION ALL SELECT 32
),

vendas_top10 AS (
    SELECT
        v.ID_CLIENT,
        TRY_TO_NUMBER(v.ID_PRODUCT) AS ID_PRODUCT,
        TRY_TO_NUMBER(v.QTD) AS QTD,
        p.CATEGORY_LIMPA
    FROM LH_NAUTICALS.QUESTAO4.VENDAS_REAL v
    INNER JOIN produtos_limpos p ON TRY_TO_NUMBER(v.ID_PRODUCT) = p.PRODUCT_ID
    INNER JOIN top_10_clientes t ON v.ID_CLIENT = t.ID_CLIENT
    WHERE TRY_TO_NUMBER(v.ID_PRODUCT) IS NOT NULL
      AND TRY_TO_NUMBER(v.QTD) IS NOT NULL
)

SELECT 
    CATEGORY_LIMPA,
    SUM(QTD) as total_quantidade_vendida
FROM vendas_top10
GROUP BY CATEGORY_LIMPA
ORDER BY total_quantidade_vendida DESC
LIMIT 1;

-- categoria e produto mais vendida e com numero de itens
WITH top_10_clientes AS (
    SELECT 47 AS ID_CLIENT
    UNION ALL SELECT 9
    UNION ALL SELECT 42
    UNION ALL SELECT 36
    UNION ALL SELECT 28
    UNION ALL SELECT 46
    UNION ALL SELECT 26
    UNION ALL SELECT 48
    UNION ALL SELECT 2
    UNION ALL SELECT 32
),

produtos_limpos AS (
    SELECT
        TRY_TO_NUMBER(CODE) AS PRODUCT_ID,
        NAME AS PRODUCT_NAME,
        CASE
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ANCORAGEM', 'ANCORAJEN', 'ENCORAGEM', 'ANCORAGUEM', 'ANCORAJM',
                'ANCORAGEM', 'ANCORAJEM', 'ENCORAGI', 'A N C O R A G E M', 'ANCORAJEM',
                'ANCORAGEN'
            ) THEN 'ANCORAGEM'
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'PROPULSAO', 'PROPULSÃO', 'PROPULÇÃO', 'PROPULÇAO', 'PROPULSAM',
                'PROP', 'PROPUÇÃO', 'P R O P U L S Ã O', 'PROPUCAO',
                'PROPULSSÃO'
            ) THEN 'PROPULSAO'
            WHEN UPPER(TRIM(ACTUAL_CATEGORY)) IN (
                'ELETRONICOS', 'ELETRÔNICOS', 'ELETRÔNICOS', 'ELETRUNICOS',
                'ELETRONICOZ', 'ELETRONISCOS', 'ELETRÔNICO', 'ELETRÔNICO',
                'ELETRONICOS', 'E L E T R Ô N I C O S'
            ) THEN 'ELETRONICOS'
            ELSE UPPER(TRIM(ACTUAL_CATEGORY))
        END AS CATEGORY_LIMPA
    FROM LH_NAUTICALS.QUESTAO2.PRODUTOS_RAW
),

compras_top10 AS (
    SELECT
        TRY_TO_NUMBER(v.ID_CLIENT) AS ID_CLIENT,
        TRY_TO_NUMBER(v.ID_PRODUCT) AS ID_PRODUCT,
        TRY_TO_NUMBER(v.QTD) AS QTD
    FROM LH_NAUTICALS.QUESTAO4.VENDAS_REAL v
    INNER JOIN top_10_clientes t
        ON TRY_TO_NUMBER(v.ID_CLIENT) = t.ID_CLIENT
    WHERE TRY_TO_NUMBER(v.ID_PRODUCT) IS NOT NULL
      AND TRY_TO_NUMBER(v.QTD) IS NOT NULL
)

SELECT
    p.CATEGORY_LIMPA,
    p.PRODUCT_ID,
    p.PRODUCT_NAME,
    SUM(c.QTD) AS total_itens_comprados
FROM compras_top10 c
INNER JOIN produtos_limpos p
    ON c.ID_PRODUCT = p.PRODUCT_ID
GROUP BY p.CATEGORY_LIMPA, p.PRODUCT_ID, p.PRODUCT_NAME
ORDER BY total_itens_comprados DESC


LIMIT 1;

-- Gráfico: Lucro acumulado dos 10 clientes mais fiéis
WITH top_10_clientes AS (
    SELECT 47 AS ID_CLIENT
    UNION ALL SELECT 9
    UNION ALL SELECT 42
    UNION ALL SELECT 36
    UNION ALL SELECT 28
    UNION ALL SELECT 46
    UNION ALL SELECT 26
    UNION ALL SELECT 48
    UNION ALL SELECT 2
    UNION ALL SELECT 32
),

vendas_top10 AS (
    SELECT
        v.ID_CLIENT,
        TRY_TO_NUMBER(v.TOTAL, 38, 2) AS TOTAL
    FROM LH_NAUTICALS.QUESTAO4.VENDAS_REAL v
    INNER JOIN top_10_clientes t ON v.ID_CLIENT = t.ID_CLIENT
    WHERE TRY_TO_NUMBER(v.TOTAL, 38, 2) IS NOT NULL
)

SELECT
    ID_CLIENT AS "Cliente",
    ROUND(SUM(TOTAL), 2) AS "Lucro Acumulado (R$)"
FROM vendas_top10
GROUP BY ID_CLIENT
ORDER BY "Lucro Acumulado (R$)" DESC;
