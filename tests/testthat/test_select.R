test_that("marginal_galaxy"{
  library(MASS)
  data(galaxies)
  set.seed(42)
  galaxies[78] <- 26960
  hypp <- Hyperparameters(type="marginal", k=3, m2.0=100)
  model <- MarginalModel(data=galaxies / 1000, k=3,
                         hypp=hypp,
                         mcmc.params=mp)
  model <- posteriorSimulation(model)
  lik.marginal <- marginalLikelihood(model, 1000L)
  expect_equal(lik.marginal, -227, tolerance=1.5)
})

.test_that("singlebatch_pooledvar"{
  library(MASS)
  data(galaxies)
  set.seed(42)
  galaxies[78] <- 26960
  hypp <- Hyperparameters(type="marginal", k=3, m2.0=100)
  model <- SingleBatchPooledVar(data=galaxies / 1000, k=3,
                                hypp=hypp,
                                mcmc.params=mp)
})

test_that("compare_galaxy_batch"{
  library(MASS)
  data(galaxies)
  set.seed(42)

  galaxies[78] <- 26960
  galaxies <- c(galaxies, galaxies + 5000)

  mp <- McmcParams(thin=10, iter=1000, burnin=10000, nStarts=20)
  hypp <- Hyperparameters(type="batch", k=2, m2.0=100)

  model <- BatchModel(data=galaxies / 1000, k=2,
                      hypp=hypp,
                      batch=rep(1:2, each=length(galaxies) / 2),
                      mcmc.params=mp)

  mlist.batch <- list(posteriorSimulation(model, k=1),
                      posteriorSimulation(model, k=2),
                      posteriorSimulation(model, k=3),
                      posteriorSimulation(model, k=4),
                      posteriorSimulation(model, k=5))

  lik.batch <- marginalLikelihood(mlist.batch)

  hypp <- Hyperparameters(type="marginal", k=2, m2.0=100)

  model <- MarginalModel(data=galaxies / 1000, k=2,
                         hypp=hypp,
                         mcmc.params=mp)

  mlist.marginal <- list(posteriorSimulation(model, k=1),
                         posteriorSimulation(model, k=2),
                         posteriorSimulation(model, k=3),
                         posteriorSimulation(model, k=4),
                         posteriorSimulation(model, k=5))

  lik.marginal <- marginalLikelihood(mlist.marginal)
  expect_true(lik.batch[3] >= max(lik.batch))
  expect_true(lik.batch[3] >= lik.marginal[3])
})

test_that("marginal_is_preferred", {
  library(MASS)
  data(galaxies)
  set.seed(42)

  galaxies[78] <- 26960
  galaxies <- c(galaxies, galaxies + 10)

  mp <- McmcParams(thin=10, iter=1000, burnin=10000, nStarts=20)
  hypp <- Hyperparameters(type="batch", k=3, m2.0=100)

  model <- BatchModel(data=galaxies / 1000, k=3,
                      hypp=hypp,
                      batch=rep(1:2, each=length(galaxies) / 2),
                      mcmc.params=mp)

  mlist.batch <- posteriorSimulation(model)
  lik.batch <- batchLikelihood(mlist.batch)

  hypp <- Hyperparameters(type="marginal", k=3, m2.0=100)

  model <- MarginalModel(data=galaxies / 1000, k=3,
                         hypp=hypp,
                         mcmc.params=mp)

  mlist.marginal <- posteriorSimulation(model)
  lik.marginal <- marginalLikelihood(mlist.marginal)
  expect_true(lik.batch <= lik.marginal)
})