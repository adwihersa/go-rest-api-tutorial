package main

import (
	"todo_api/internal/config"
	"todo_api/internal/database"
	"todo_api/internal/handlers"

	"github.com/gin-gonic/gin"
)

func main() {
	var cfg *config.Config
	var err error
	cfg, err = config.Load()

	if err != nil {
		panic("Failed to load configuration: " + err.Error())
	}

	// var pool *pgxpool.Pool
	pool, err := database.Connect(cfg.DatabaseURL)

	if err != nil {
		panic("Failed to connect to database: " + err.Error())
	}

	defer pool.Close()

	var router *gin.Engine = gin.Default()
	router.SetTrustedProxies(nil)
	router.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message":  "pong",
			"status":   "success",
			"database": "connected",
		})
	})

	router.GET("/todos", handlers.GetAllTodosHandler(pool))
	router.POST("/todos", handlers.CreateTodoHandler(pool))
	router.GET("/todos/:id", handlers.GetTodoByIdHandler(pool))
	router.PUT("/todos/:id", handlers.UpdateTodoHandler(pool))
	router.DELETE("/todos/:id", handlers.DeleteTodoHandler(pool))

	router.Run(":" + cfg.Port) // listens on 0.0.0.0:4000  by default
}
