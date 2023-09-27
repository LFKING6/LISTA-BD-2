DELIMITER //
CREATE PROCEDURE sp_ListarAutores()
BEGIN
    SELECT * FROM Autor;
END //
DELIMITER ;
CALL sp_ListarAutores();

DELIMITER //
CREATE PROCEDURE sp_LivrosPorCategoria(IN categoriaNome VARCHAR(100))
BEGIN
    SELECT Livro.Titulo
    FROM Livro
    INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
    WHERE Categoria.Nome = categoriaNome;
END //
DELIMITER ;
CALL sp_LivrosPorCategoria('Romance');

DELIMITER //
CREATE PROCEDURE sp_ContarLivrosPorCategoria(IN categoriaNome VARCHAR(100))
BEGIN
    SELECT COUNT(Livro.Titulo) AS TotalLivros
    FROM Livro
    INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
    WHERE Categoria.Nome = categoriaNome;
END //
DELIMITER ;
CALL sp_ContarLivrosPorCategoria('Ciência');

DELIMITER //
CREATE PROCEDURE sp_VerificarLivrosCategoria(IN categoriaNome VARCHAR(100))
BEGIN
    DECLARE contador INT;
    
    SELECT COUNT(Livro.Titulo) INTO contador
    FROM Livro
    INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
    WHERE Categoria.Nome = categoriaNome;
    
    IF contador > 0 THEN
        SELECT 'Existem livros nesta categoria.' AS Mensagem;
    ELSE
        SELECT 'Não existem livros nesta categoria.' AS Mensagem;
    END IF;
END //
DELIMITER ;
CALL sp_VerificarLivrosCategoria('Ficção Científica');

DELIMITER //
CREATE PROCEDURE sp_LivrosAteAno(IN anoPublicacao INT)
BEGIN
    SELECT Titulo
    FROM Livro
    WHERE Ano_Publicacao <= anoPublicacao;
END //
DELIMITER ;
CALL sp_LivrosAteAno(2010);

DELIMITER //
CREATE PROCEDURE sp_TitulosPorCategoria(IN categoriaNome VARCHAR(100))
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE livroTitulo VARCHAR(255);
    DECLARE cur CURSOR FOR
        SELECT Livro.Titulo
        FROM Livro
        INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
        WHERE Categoria.Nome = categoriaNome;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO livroTitulo;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT livroTitulo AS Titulo;
    END LOOP;

    CLOSE cur;
END //
DELIMITER ;
CALL sp_TitulosPorCategoria('História');

DELIMITER //
CREATE PROCEDURE sp_AdicionarLivro(IN livroTitulo VARCHAR(255), IN editoraID INT, IN anoPublicacao INT, IN numeroPaginas INT, IN categoriaID INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Erro: Não foi possível adicionar o livro.' AS Mensagem;
    END;
    
    START TRANSACTION;
    
    INSERT INTO Livro (Titulo, Editora_ID, Ano_Publicacao, Numero_Paginas, Categoria_ID)
    VALUES (livroTitulo, editoraID, anoPublicacao, numeroPaginas, categoriaID);
    
    COMMIT;
    
    SELECT 'Livro adicionado com sucesso.' AS Mensagem;
END //
DELIMITER ;
CALL sp_AdicionarLivro('A Guerra dos Tronos', 1, 2022, 200, 2);

DELIMITER //
CREATE PROCEDURE sp_AutorMaisAntigo()
BEGIN
    SELECT Nome, Sobrenome
    FROM Autor
    WHERE Data_Nascimento = (SELECT MIN(Data_Nascimento) FROM Autor);
END //
DELIMITER ;
CALL sp_AutorMaisAntigo();

-- Define um novo delimitador para permitir o uso de ';' dentro da procedure
DELIMITER //

-- Cria a stored procedure
CREATE PROCEDURE sp_AutorMaisAntigo()
BEGIN
    -- Seleciona os campos Nome e Sobrenome da tabela Autor
    -- onde a Data de Nascimento é igual à data de nascimento mínima
    -- obtida de outra subconsulta na tabela Autor.
    SELECT Nome, Sobrenome
    FROM Autor
    WHERE Data_Nascimento = (SELECT MIN(Data_Nascimento) FROM Autor);
END //

-- Restaure o delimitador padrão
DELIMITER ;